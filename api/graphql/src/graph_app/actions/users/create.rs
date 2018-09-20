use diesel::pg::PgConnection;
use failure::Error;
use models::user::{User, UserAttrs};
use validator::Validate;

pub fn call(conn: &PgConnection, user_attrs: UserAttrs) -> Result<User, Error> {
	user_attrs
		.validate()
		.map_err(|e| format_err!("{}", e.to_string()))?;

	let user = User::create(conn, user_attrs).map_err(|e| format_err!("{}", e.to_string()))?;

	Ok(user)
}
