use crate::models::user::{Role, User};
use diesel::PgConnection;
use failure::Error;

pub fn can_create(_conn: &PgConnection, current_user: &User) -> Result<bool, Error> {
	let is_authorised = current_user.role == Role::Admin;

	Ok(is_authorised)
}

pub fn can_archive(conn: &PgConnection, current_user: &User, user_id: i32) -> Result<bool, Error> {
	if current_user.role != Role::Admin {
		return Ok(false);
	}

	let user = User::find(&conn, user_id)?;

	let is_authorised = current_user.client_id == user.client_id;

	Ok(is_authorised)
}
