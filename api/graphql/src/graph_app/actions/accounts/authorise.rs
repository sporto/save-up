// use diesel;
use diesel::prelude::*;
use diesel::PgConnection;
use failure::Error;

use models;
use models::account::Account;
use models::schema as db;
use models::user::{Role, User};

pub fn can_access(
	conn: &PgConnection,
	account_id: i32,
	current_user: &User,
) -> Result<bool, Error> {
	// Ok if account holder
	let account = Account::find(&conn, account_id)?;

	if account.user_id == current_user.id {
		return Ok(true);
	}

	// Ok if admin for this client
	can_admin(conn, account_id, current_user)
}

pub fn can_admin(conn: &PgConnection, account_id: i32, current_user: &User) -> Result<bool, Error> {
	// Ok if admin for this client
	let account = Account::find(&conn, account_id)?;

	let admins_ids = get_admin_ids(&conn, &account)?;

	let has_access = admins_ids.contains(&current_user.id);

	Ok(has_access)
}

fn get_admin_ids(conn: &PgConnection, account: &Account) -> Result<Vec<i32>, Error> {
	let user = User::find(&conn, account.user_id)?;

	let _client = models::client::Client::find(&conn, user.client_id)?;

	let is_in_client = db::users::client_id.eq(user.client_id);

	let is_admin = db::users::role.eq(Role::Admin);

	let admin_filter = is_in_client.and(is_admin);

	db::users::table
		.select(db::users::id)
		.filter(admin_filter)
		.get_results(conn)
		.map_err(|e| format_err!("{}", e))
}

#[cfg(test)]
mod tests {
	use super::*;
	use utils::tests;

	#[test]
	fn is_true_for_the_user() {
		tests::with_db(|conn| {
			let (account, user, _) = tests::account(&conn);

			let response = can_access(conn, account.id, &user).unwrap();

			assert!(response);
		})
	}

	fn is_false_for_other_users() {
		tests::with_db(|conn| {
			let (account, _, _) = tests::account(&conn);

			let (other_user, _) = tests::user(&conn);

			let response = can_access(conn, account.id, &other_user).unwrap();

			assert!(response == false);
		})
	}

	fn is_true_for_admin() {
		tests::with_db(|conn| {
			let (account, _user, client) = tests::account(&conn);

			let admin = tests::admin_for(&conn, &client);

			let response = can_access(conn, account.id, &admin).unwrap();

			assert!(response);
		})
	}

	fn is_false_for_other_admins() {
		tests::with_db(|conn| {
			let (account, _, _) = tests::account(&conn);

			let other_client = tests::client(&conn);

			let other_admin = tests::admin_for(&conn, &other_client);

			let response = can_access(conn, account.id, &other_admin).unwrap();

			assert!(response);
		})
	}
}
