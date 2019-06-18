use crate::{
	actions::passwords,
	models::{sign_in::SignIn, user::User},
};
use diesel::pg::PgConnection;
use failure::Error;

pub fn call(conn: &PgConnection, sign_in: SignIn) -> Result<User, Error> {
	let invalid = "Invalid username, email or password";

	let user = User::find_by_username_or_email(conn, &sign_in.username_or_email)
		.map_err(|e| format_err!("{}", e))
		.map_err(|_| format_err!("{}", invalid))?;

	let valid = passwords::verify::call(&sign_in.password, &user.password_hash)
		.map_err(|_| format_err!("{}", invalid))?;

	if valid {
		Ok(user)
	} else {
		Err(format_err!("{}", invalid))
	}
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::actions::passwords;
	use crate::models;
	use crate::utils::tests;

	#[test]
	fn it_can_sign_in() {
		tests::with_db(|conn| {
			let password = "password".to_string();

			let email = "sam@sample.com".to_owned();

			let password_hash = passwords::encrypt::call(&password).unwrap();

			let client = models::client::factories::client_attrs().save(conn);

			let user = models::user::factories::user_attrs(&client)
				.email(Some(email.clone()))
				.password_hash(&password_hash)
				.save(conn);

			let sign_in = SignIn {
				username_or_email: email,
				password:          password,
			};

			let result = call(&conn, sign_in);

			assert!(result.is_ok());

			let returned_user = result.unwrap();

			assert_eq!(returned_user.email, user.email);
		})
	}

	#[test]
	fn it_can_sign_in_with_username() {
		tests::with_db(|conn| {
			let username = "sample".to_owned();

			let password = "password".to_string();

			let password_hash = passwords::encrypt::call(&password).unwrap();

			let client = models::client::factories::client_attrs().save(conn);

			let user = models::user::factories::user_attrs(&client)
				.username(&username)
				.password_hash(&password_hash)
				.save(conn);

			let sign_in = SignIn {
				username_or_email: username,
				password:          password,
			};

			let result = call(&conn, sign_in);

			assert!(result.is_ok());

			let returned_user = result.unwrap();

			assert_eq!(returned_user.username, user.username);
		})
	}

	#[test]
	fn it_rejects_duplicated_usernames() {
		// TODO
	}

	#[test]
	fn it_cant_sign_in_with_wrong_password() {
		tests::with_db(|conn| {
			let password = "password".to_string();

			let email = "sam@sample.com".to_owned();

			let password_hash = passwords::encrypt::call(&password).unwrap();

			let client = models::client::factories::client_attrs().save(conn);

			let _user = models::user::factories::user_attrs(&client)
				.email(Some(email.clone()))
				.password_hash(&password_hash)
				.save(conn);

			let sign_in = SignIn {
				username_or_email: email,
				password:          "other".to_owned(),
			};

			let result = call(&conn, sign_in);

			assert!(result.is_err());
		})
	}
}
