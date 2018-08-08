use bcrypt::{verify};
use models::users::{User};
use models::sign_ins::SignIn;
use diesel::pg::PgConnection;

pub fn call(conn: &PgConnection, sign_in: SignIn) -> Result<User, String> {

	User::find_by_email(conn, &sign_in.email)
		.map_err(|_| "User not found".to_owned() )
		.and_then(|user| {

			verify(
				&sign_in.password,
				&user.password_hash,
				)
				.map_err(|_| "Invalid password".to_owned() )
				.map(|_| user )

		}).map_err(|_|
			"Invalid email or password".to_owned()
		)

}

