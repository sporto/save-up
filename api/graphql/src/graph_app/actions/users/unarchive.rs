use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use failure::Error;
use models::schema as db;
use models::user::UserChangeset;

pub fn call(conn: &PgConnection, user_id: i32) -> Result<usize, Error> {
	let changes = UserChangeset {
		archived_at: Some(None),
	};

	diesel::update(db::users::table.filter(db::users::id.eq(user_id)))
		.set(changes)
		.execute(conn)
		.map_err(|e| format_err!("{}", e))
}
