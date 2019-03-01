use crate::models::{schema as db, user::UserChangeset};
use diesel::{self, pg::PgConnection, prelude::*};
use failure::Error;

pub fn call(conn: &PgConnection, user_id: i32) -> Result<usize, Error> {
	let changes = UserChangeset {
		archived_at: Some(None),
	};

	diesel::update(db::users::table.filter(db::users::id.eq(user_id)))
		.set(changes)
		.execute(conn)
		.map_err(|e| format_err!("{}", e))
}
