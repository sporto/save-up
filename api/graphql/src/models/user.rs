pub use super::role::Role;
use super::schema::users;
use chrono::NaiveDateTime;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;
use regex::Regex;
use validator::Validate;

lazy_static! {
	pub static ref USERNAME_RE: Regex = Regex::new(r"^[A-Za-z0-9]+(?:[_-][A-Za-z0-9]+)*$").unwrap();
}

#[derive(Queryable, Debug, Clone)]
pub struct User {
	pub id: i32,
	pub created_at: NaiveDateTime,
	pub client_id: i32,
	pub email: Option<String>,
	pub password_hash: String,
	pub name: String,
	pub role: Role,
	pub email_confirmation_token: Option<String>,
	pub email_confirmed_at: Option<NaiveDateTime>,
	pub username: String,
}

#[derive(Insertable, Validate, Clone)]
#[table_name = "users"]
pub struct UserAttrs {
	pub client_id: i32,
	#[validate(email)]
	pub email: Option<String>,
	pub password_hash: String,
	#[validate(length(min = "1"))]
	pub name: String,
	pub role: Role,
	pub email_confirmation_token: Option<String>,
	pub email_confirmed_at: Option<NaiveDateTime>,
	#[validate(length(min = "5"))]
	#[validate(regex = "USERNAME_RE")]
	pub username: String,
}

#[derive(Serialize, Deserialize)]
pub struct TokenClaims {
	#[serde(rename = "userId")]
	pub user_id: i32,
	pub username: String,
	pub name: String,
	pub email: Option<String>,
	pub role: Role,
	pub exp: i64,
}

#[allow(dead_code)]
pub fn system_user() -> User {
	let created_at = NaiveDateTime::from_timestamp(1_000_000_000, 0);

	User {
		id: 0,
		created_at: created_at,
		email: Some("app@saveup.app".to_owned()),
		username: "SYSTEM".to_owned(),
		name: "SYSTEM".to_owned(),
		client_id: 0,
		password_hash: "".to_owned(),
		role: Role::Admin,
		email_confirmation_token: None,
		email_confirmed_at: None,
	}
}

impl User {
	// Scopes
	// pub fn is_investor() -> diesel::expression::operators::Eq<i32, i32> {
	// 	db::users::role.eq(Role::Investor)
	// }

	// Create
	#[allow(dead_code)]
	pub fn create(conn: &PgConnection, attrs: UserAttrs) -> Result<User, Error> {
		diesel::insert_into(users::dsl::users)
			.values(&attrs)
			.get_result(conn)
	}

	// Read
	#[allow(dead_code)]
	pub fn all(conn: &PgConnection) -> Vec<User> {
		users::table
			.load::<User>(conn)
			.expect("Error loading users")
	}

	#[allow(dead_code)]
	pub fn find(conn: &PgConnection, user_id: i32) -> Result<User, Error> {
		users::table.find(user_id).first::<User>(conn)
	}

	#[allow(dead_code)]
	pub fn find_by_email(conn: &PgConnection, email: &str) -> Result<User, Error> {
		users::table
			.filter(users::email.eq(email))
			.first::<User>(conn)
	}

	#[allow(dead_code)]
	pub fn find_by_username_or_email(conn: &PgConnection, input: &str) -> Result<User, Error> {
		let filter = users::username.eq(input).or(users::email.eq(input));
		users::table.filter(filter).first::<User>(conn)
	}
}

#[cfg(test)]
pub mod factories {
	use super::*;
	use models::client::Client;

	#[allow(dead_code)]
	pub fn user_attrs(client: &Client) -> UserAttrs {
		UserAttrs {
			client_id: client.id,
			email: None,
			password_hash: "abc".to_owned(),
			name: "Sam".to_owned(),
			role: Role::Admin,
			email_confirmation_token: None,
			email_confirmed_at: None,
			username: "sam".to_owned(),
		}
	}

	pub fn user_attrs_alone() -> UserAttrs {
		UserAttrs {
			client_id: 1,
			email: None,
			password_hash: "abc".to_owned(),
			name: "Sam".to_owned(),
			role: Role::Admin,
			email_confirmation_token: None,
			email_confirmed_at: None,
			username: "sam".to_owned(),
		}
	}

	impl UserAttrs {
		pub fn save(self, conn: &PgConnection) -> User {
			User::create(conn, self).unwrap()
		}

		pub fn email(self, email: Option<String>) -> Self {
			UserAttrs { email, ..self }
		}

		pub fn username(self, username: &str) -> Self {
			UserAttrs {
				username: username.to_string(),
				..self
			}
		}

		pub fn role(self, role: Role) -> Self {
			UserAttrs { role, ..self }
		}

		pub fn password_hash(self, password_hash: &str) -> Self {
			UserAttrs {
				password_hash: password_hash.to_string(),
				..self
			}
		}

		pub fn email_confirmation_token(self, token: &str) -> Self {
			UserAttrs {
				email_confirmation_token: Some(token.to_string()),
				..self
			}
		}
	}

	impl User {
		pub fn delete_all(conn: &PgConnection) -> Result<usize, Error> {
			diesel::delete(users::table).execute(conn)
		}
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn it_validates_username() {
		let attrs = factories::user_attrs_alone().username("sammma");
		assert!(attrs.validate().is_ok());
	}

	#[test]
	fn it_rejects_invalid() {
		let attrs = factories::user_attrs_alone().username("sam mma");
		assert!(attrs.validate().is_err());
	}
}
