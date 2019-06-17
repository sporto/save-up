use crate::{
	actions::emails::send,
	models::{ schema as db, user::User},
	utils::links,
};
use shared::emails::{Email, EmailKind};
use diesel::{self, pg::PgConnection, prelude::*};
use failure::Error;
use uuid::Uuid;

pub fn call(conn: &PgConnection, username_or_email: &str) -> Result<String, Error> {
	let user = User::find_by_username_or_email(&conn, username_or_email)?;

	let token = Uuid::new_v4().to_string();

	let reset_url = links::reset_url(&token)?;

	let email_address = match user.email {
		Some(ref email) => email,
		None => return Err(format_err!("No email found for this user")),
	};

	diesel::update(db::users::table.filter(db::users::id.eq(user.id)))
		.set(db::users::password_reset_token.eq(token.clone()))
		.execute(conn)
		.map_err(|e| format_err!("{}", e))?;

	let email_kind = EmailKind::ResetPassword {
		reset_url: reset_url.to_string(),
	};

	let email = Email {
		to: email_address.to_string(),
		kind: email_kind,
	};

	send::call(&email)?;

	Ok(token)
}
