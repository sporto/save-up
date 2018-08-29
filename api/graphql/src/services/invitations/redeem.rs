use bigdecimal::BigDecimal;
use bigdecimal::FromPrimitive;
use chrono::prelude::*;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use failure::Error;

use models::account::{Account, AccountAttrs};
use models::cents::Cents;
use models::invitation;
use models::schema::invitations;
use models::user::{self, User, UserAttrs, ROLE_INVESTOR};
use services;

#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct RedeemInvitationInput {
	pub name: String,
	pub password: String,
	pub token: String,
}

pub fn call(conn: &PgConnection, input: &RedeemInvitationInput) -> Result<User, Error> {
	let invitation = invitation::Invitation::find_by_token(&conn, &input.token)?;

	// Find the client id
	let inviter = user::User::find(&conn, invitation.user_id)?;

	let password_hash =
		services::passwords::encrypt::call(&input.password).map_err(|e| format_err!("{}", e))?;

	// Email for users created via invitation don't need to be confirmed
	let email_confirmed_at = Some(Utc::now().naive_utc());

	let user_attrs = UserAttrs {
		client_id: inviter.client_id,
		role: ROLE_INVESTOR.to_string(),
		name: input.clone().name,
		email: invitation.email,
		password_hash: password_hash,
		email_confirmed_at: email_confirmed_at,
		email_confirmation_token: None,
	};

	// Transaction should be here

	let user = User::create(conn, user_attrs).map_err(|e| format_err!("{}", e))?;

	// Create an account for this user´
	let account_attrs = AccountAttrs {
		user_id: user.id,
		name: "Default".into(),
		yearly_interest: BigDecimal::from_u8(20).unwrap(),
	};

	Account::create(conn, account_attrs).map_err(|e| format_err!("{}", e))?;

	let now = Utc::now().naive_utc();

	// Save the invitation used_at
	diesel::update(invitations::table.filter(invitations::id.eq(invitation.id)))
		.set(invitations::used_at.eq(now))
		.execute(conn)?;

	Ok(user)
}

#[cfg(test)]
mod tests {
	use super::*;
	use models::client;
	use utils::tests;

	#[test]
	fn it_creates_a_user() {
		tests::with_db(|conn| {
			let client = client::factories::client_attrs().save(conn);
			let inviter = user::factories::user_attrs(&client).save(conn);

			let invitation_token = "token".into();

			let invitation = invitation::factories::invitation_attrs(&inviter)
				.token(invitation_token)
				.save(conn);

			let input = RedeemInvitationInput {
				name: "Julia".into(),
				password: "password".into(),
				token: invitation_token.into(),
			};

			// creates the user
			let user = call(&conn, &input).unwrap();

			// sets the correct client
			assert_eq!(user.client_id, inviter.client_id);

			// And creates an account for the user
			let account = Account::find_by_user_id(conn, user.id).unwrap();

			assert_eq!(account.user_id, user.id);
		})
	}

}
