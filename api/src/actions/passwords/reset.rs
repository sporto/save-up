use crate::{
	actions::passwords,
	models::{schema as db, user::User},
};
use diesel::{self, pg::PgConnection, prelude::*};
use failure::Error;

pub fn call(conn: &PgConnection, token: &str, password: &str) -> Result<User, Error> {
	let user = User::find_by_password_reset_token(conn, token)?;

	let password_hash = passwords::encrypt::call(password)?;

	diesel::update(db::users::table.filter(db::users::id.eq(user.id)))
		.set(db::users::password_hash.eq(password_hash.clone()))
		.execute(conn)
		.map_err(|e| format_err!("{}", e))?;

	Ok(user)
}
