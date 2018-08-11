use diesel::pg::PgConnection;
use models::invitations::{Invitation, InvitationAttrs};
use models::users::{User, ROLE_INVESTOR};
use uuid::Uuid;
use validator::Validate;

pub fn call(conn: &PgConnection, user: &User, email: &str) -> Result<Invitation, String> {
	let token = Uuid::new_v4();

	let invitation_attrs = InvitationAttrs {
		user_id: user.id,
		email: email.to_string(),
		role: ROLE_INVESTOR.to_string(),
		token: token.to_string(),
		used_at: None,
	};

	invitation_attrs.validate().map_err(|e| e.to_string())?;

	let invitation = Invitation::create(conn, invitation_attrs).map_err(|e| e.to_string())?;

	Ok(invitation)
}

#[cfg(test)]
mod tests {
	use super::*;
	use models;
	use utils::tests;

	#[test]
	fn it_creates_an_invitation() {
		tests::with_db(|conn| {
			let client = models::clients::client_attrs().save(conn);
			let user = models::users::user_attrs(&client).save(conn);
			let email = "samantha@sample.com".to_owned();

			let result = call(&conn, &user, &email);

			assert!(result.is_ok());

			let invitation = result.unwrap();

			assert_eq!(invitation.email, email);
		})
	}
}
