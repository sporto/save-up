use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use failure::Error;
use graph_common::actions::emails::send;
use models::schema as db;
use models::user::User;
use shared::email_kinds::EmailKind;
use uuid::Uuid;

pub fn call(conn: &PgConnection, username_or_email: &str) -> Result<String, Error> {
	let user = User::find_by_username_or_email(&conn, username_or_email)?;

	let token = Uuid::new_v4().to_string();

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
		token: token.to_string(),
	};

	send::call(&email_kind)?;

	Ok(token)
}
