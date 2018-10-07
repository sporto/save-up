use actions::emails::send;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use failure::Error;
use models::email_kinds::EmailKind;
use models::schema as db;
use models::user::User;
use utils::links;
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
		email: email.to_string(),
		reset_url: reset_url.to_string(),
	};

	send::call(&email_kind)?;

	Ok(token)
}
