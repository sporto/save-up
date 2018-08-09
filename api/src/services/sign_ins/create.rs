use bcrypt::verify;
use diesel::pg::PgConnection;
use models::sign_ins::SignIn;
use models::users::User;
use services::passwords;

pub fn call(conn: &PgConnection, sign_in: SignIn) -> Result<User, String> {
	User::find_by_email(conn, &sign_in.email)
		.map_err(|_| "User not found".to_owned())
		.and_then(|user| {
			verify(&sign_in.password, &user.password_hash)
				.map_err(|_| "Invalid password".to_owned())
				.map(|_| user)
		})
		.map_err(|_| "Invalid email or password".to_owned())
}

#[cfg(test)]
mod tests {
	use super::*;
	use models;
	use utils::tests;

	#[test]
	fn it_can_sign_in() {
		tests::with_db(|conn| {
			let password = "password".to_string();

			let password_hash = passwords::encrypt::call(&password).unwrap();

			let client = models::clients::client()
				.save(conn);

			let user = models::users::user(&client)
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
}
