use chrono::prelude::*;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error as DieselError;
use failure::Error;

use graph_common::actions::accounts;
use graph_common::actions::passwords;
use models::invitation;
use models::schema::invitations;
use models::user::{self, Role, User, UserAttrs};

#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct RedeemInvitationInput {
	pub username: String,
	pub name: String,
	pub password: String,
	pub token: String,
}

pub fn call(conn: &PgConnection, input: &RedeemInvitationInput) -> Result<User, Error> {
	let invitation =
		invitation::Invitation::find_by_token(&conn, &input.token).map_err(|e| match e {
			DieselError::NotFound => format_err!("Invalid invitation token"),
			_ => format_err!("{}", e),
		})?;

	// Find the client id
	let inviter = user::User::find(&conn, invitation.user_id)?;

	let password_hash =
		passwords::encrypt::call(&input.password).map_err(|e| format_err!("{}", e))?;

	// Email for users created via invitation don't need to be confirmed
	let email_confirmed_at = Some(Utc::now().naive_utc());

	let user_attrs = UserAttrs {
		client_id: inviter.client_id,
		role: Role::Investor,
		username: input.clone().username,
		name: input.clone().name,
		email: Some(invitation.email),
		password_hash: password_hash,
		email_confirmed_at: email_confirmed_at,
		email_confirmation_token: None,
	};

	// Transaction should be here

	let user = User::create(conn, user_attrs).map_err(|e| format_err!("{}", e))?;

	let _account = accounts::create::call(conn, &user)?;

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
	use models::account::Account;
	use models::client;
	use utils::tests;

	#[test]
	fn it_creates_a_user() {
		tests::with_db(|conn| {
			let client = client::factories::client_attrs().save(conn);
			let inviter = user::factories::user_attrs(&client).save(conn);

			let invitation_token = "token".into();

			let _invitation = invitation::factories::invitation_attrs(&inviter)
				.token(invitation_token)
				.save(conn);

			let input = RedeemInvitationInput {
				name: "Julia".into(),
				username: "username".to_string(),
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
