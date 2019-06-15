use crate::{
	actions,
	models::{
		role::Role,
		user::{User, UserAttrs},
	},
};
use diesel::pg::PgConnection;
use failure::Error;
use validator::Validate;
use crate::utils::validations;

pub fn call(conn: &PgConnection, user_attrs: UserAttrs) -> Result<User, Error> {
	user_attrs
		.validate()
		.map_err(|e| format_err!("{}", validations::to_human_error(e)))?;

	let user = User::create(conn, user_attrs).map_err(|e| format_err!("{}", e.to_string()))?;

	if user.role == Role::Investor {
		let _account = actions::accounts::create::call(conn, &user);
	}

	Ok(user)
}

#[cfg(test)]
mod tests {
	use super::*;
	use models;
	use utils::tests;

	#[test]
	fn it_enforces_unique_usernames() {
		tests::with_db(|conn| {
			let username = "username";

			let client = models::client::factories::client_attrs().save(conn);

			let user_attrs = models::user::factories::user_attrs(&client).username(username);

			let result_1 = User::create(conn, user_attrs.clone());

			let result_2 = User::create(conn, user_attrs);

			assert!(result_1.is_ok());
			assert!(result_2.is_err());
		})
	}

	#[test]
	fn it_enforces_unique_email() {
		tests::with_db(|conn| {
			let email = "sam@sample.com".to_string();

			let client = models::client::factories::client_attrs().save(conn);

			let user_attrs = models::user::factories::user_attrs(&client).email(Some(email));

			let result_1 = User::create(conn, user_attrs.clone());

			let result_2 = User::create(conn, user_attrs);

			assert!(result_1.is_ok());
			assert!(result_2.is_err());
		})
	}
}
