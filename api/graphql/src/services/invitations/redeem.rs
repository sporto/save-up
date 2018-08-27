use chrono::prelude::*;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use failure::Error;
use models::invitation;
use models::schema::invitations;
use models::client;
use models::user::{self, User, UserAttrs, ROLE_INVESTOR};
use services;

#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct InvitationUseInput {
	pub name: String,
	pub password: String,
	pub token: String,
}

pub fn call(conn: &PgConnection, input: &InvitationUseInput) -> Result<User, Error> {
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

	// Transaction here
	let user = User::create(conn, user_attrs).map_err(|e| format_err!("{}", e))?;

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
	use utils::tests;

	#[test]
	fn it_creates_a_user() {
		tests::with_db(|conn| {
			let client = client::client_attrs().save(conn);
			let inviter = user::user_attrs(&client).save(conn);

			let invitation_token = "token".into();

			let invitation = invitation::invitation_attrs(&inviter)
				.token(invitation_token)
				.save(conn);

			let input = InvitationUseInput {
				name: "Julia".into(),
				password: "password".into(),
				token: invitation_token.into(),
			};

			// creates the user
			let returned_user = call(&conn, &input).unwrap();

			// sets the correct client
			assert_eq!(returned_user.client_id, inviter.client_id);

			// sets the use at 
		})
	}
}
