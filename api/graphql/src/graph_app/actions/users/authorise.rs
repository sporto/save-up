use diesel::PgConnection;
use failure::Error;
use models::user::{Role, User};

pub fn can_create(_conn: &PgConnection, current_user: &User) -> Result<bool, Error> {
	let is_authorised = current_user.role == Role::Admin;

	Ok(is_authorised)
}
