use chrono::prelude::*;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use failure::Error;
use models::schema as db;

pub fn call(conn: &PgConnection, user_id: i32) -> Result<usize, Error> {
	let now = Utc::now().naive_utc();

	diesel::update(db::users::table.filter(db::users::id.eq(user_id)))
		.set(db::users::archived_at.eq(now))
		.execute(conn)
		.map_err(|e| format_err!("{}", e))
}
