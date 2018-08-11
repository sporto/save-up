use bcrypt::verify;
use diesel::pg::PgConnection;
use models::sign_ins::SignIn;
use models::users::User;

pub fn call(conn: &PgConnection, sign_in: SignIn) -> Result<User, String> {
	let user = User::find_by_email(conn, &sign_in.email)
		.map_err(|_| "User not found".to_owned())?;

	let invalid = "Invalid email or password".to_owned();

	let valid = verify(&sign_in.password, &user.password_hash)
		.map_err(|_| invalid.clone())?;

	if valid {
		Ok(user)
	} else {
		Err(invalid)
	}
}

#[cfg(test)]
mod tests {
	use super::*;
	use models;
	use utils::tests;
	use services::passwords;

	#[test]
	fn it_can_sign_in() {
		tests::with_db(|conn| {
			let password = "password".to_string();

			let password_hash = passwords::encrypt::call(&password).unwrap();

			let client = models::clients::client_attrs().save(conn);

			let user = models::users::user_attrs(&client)
				.password_hash(&password_hash)
				.save(conn);

			let sign_in = SignIn {
				email: user.email.clone(),
				password: password,
			};

			let result = call(&conn, sign_in);

			assert!(result.is_ok());

			let returned_user = result.unwrap();

			assert_eq!(returned_user.email, user.email);
		})
	}

	#[test]
	fn it_cant_sign_in_with_wrong_password() {
		tests::with_db(|conn| {
			let password = "password".to_string();

			let password_hash = passwords::encrypt::call(&password).unwrap();

			let client = models::clients::client_attrs().save(conn);

			let user = models::users::user_attrs(&client)
				.password_hash(&password_hash)
				.save(conn);

			let sign_in = SignIn {
				email: user.email.clone(),
				password: "other".to_owned(),
			};

			let result = call(&conn, sign_in);

			assert!(result.is_err());
		})
	}
}
