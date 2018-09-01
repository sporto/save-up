// use diesel;
use diesel::prelude::*;
use diesel::PgConnection;
use failure::Error;

use models;
use models::account::Account;
use models::schema as db;
use models::user::{User, ROLE_ADMIN};

pub fn access(conn: &PgConnection, account_id: i32, accessing_user: &User) -> Result<bool, Error> {
	// Ok if account holder
	let account = Account::find(&conn, account_id)?;

	if account.user_id == accessing_user.id {
		return Ok(true);
	}

	// Ok if admin for this client
	let admins_ids = get_admin_ids(&conn, &account)?;

	let has_access = admins_ids.contains(&accessing_user.id);

	Ok(has_access)
}

fn get_admin_ids(conn: &PgConnection, account: &Account) -> Result<Vec<i32>, Error> {
	let user = User::find(&conn, account.user_id)?;

	let _client = models::client::Client::find(&conn, user.client_id)?;

	let is_in_client = db::users::client_id.eq(user.client_id);

	let is_admin = db::users::role.eq(ROLE_ADMIN);

	let admin_filter = is_in_client.and(is_admin);

	db::users::table
		.select(db::users::id)
		.filter(admin_filter)
		.get_results(conn)
		.map_err(|e| format_err!("{}", e))
}
