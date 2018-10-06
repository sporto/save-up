use actions::passwords;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use failure::Error;
use models::schema as db;
use models::user::User;

pub fn call(conn: &PgConnection, token: &str, password: &str) -> Result<User, Error> {
	let user = User::find_by_password_reset_token(conn, token)?;

	let password_hash = passwords::encrypt::call(password)?;

	diesel::update(db::users::table.filter(db::users::id.eq(user.id)))
		.set(db::users::password_hash.eq(password_hash.clone()))
		.execute(conn)
		.map_err(|e| format_err!("{}", e))?;

	Ok(user)
}
