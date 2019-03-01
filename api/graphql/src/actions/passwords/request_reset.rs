use crate::{
	actions::emails::send,
	models::{email_kinds::EmailKind, schema as db, user::User},
	utils::links,
};
use diesel::{self, pg::PgConnection, prelude::*};
use failure::Error;
use uuid::Uuid;

pub fn call(conn: &PgConnection, username_or_email: &str) -> Result<String, Error> {
	let user = User::find_by_username_or_email(&conn, username_or_email)?;

	let token = Uuid::new_v4().to_string();

	let reset_url = links::reset_url(&token)?;

	let email = match user.email {
		Some(ref email) => email,
		None => return Err(format_err!("No email found for this user")),
	};

	diesel::update(db::users::table.filter(db::users::id.eq(user.id)))
		.set(db::users::password_reset_token.eq(token.clone()))
		.execute(conn)
		.map_err(|e| format_err!("{}", e))?;

	let email_kind = EmailKind::ResetPassword {
		email:     email.to_string(),
		reset_url: reset_url.to_string(),
	};

	send::call(&email_kind)?;

	Ok(token)
}
