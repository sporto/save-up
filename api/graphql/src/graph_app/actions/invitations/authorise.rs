use diesel::PgConnection;
use failure::Error;

// use models;
// use models::schema as db;
use models::user::{Role, User};

pub fn call(_conn: &PgConnection, current_user: &User) -> Result<bool, Error> {
	let is_authorised = current_user.role == Role::Admin;

	Ok(is_authorised)
}
