use chrono::prelude::*;
use diesel;
use diesel::prelude::*;
use failure::Error;

use models::schema::users;
use models::user;

pub fn call(conn: &PgConnection, token: &str) -> Result<user::User, Error> {
	// Find a user with this token
	let condition = users::table.filter(users::email_confirmation_token.eq(token));

	let now = Utc::now().naive_utc();

	let change = users::email_confirmed_at.eq(now);

	let updated_user: user::User = diesel::update(condition).set(change).get_result(conn)?;

	Ok(updated_user)
}

#[cfg(test)]
mod tests {
	use super::*;
	use models::client;
	use utils::tests;

	#[test]
	fn it_updates_the_user() {
		tests::with_db(|conn| {
			let client = client::factories::client_attrs().save(conn);

			let _user = user::factories::user_attrs(&client)
				.email_confirmation_token("xyz")
				.save(conn);

			let returned_user = call(&conn, "xyz").unwrap();

			assert!(returned_user.email_confirmed_at != None)
		})
	}

	#[test]
	fn it_returns_error_when_token_not_found() {
		tests::with_db(|conn| {
			let client = client::factories::client_attrs().save(conn);

			let _user = user::factories::user_attrs(&client)
				.email_confirmation_token("abc")
				.save(conn);

			let result = call(&conn, "xyz");

			assert!(result.is_err(), "should not find token")
		})
	}

}
