pub use super::role::Role;
// use super::schema as db;
use super::schema::users;
use chrono::NaiveDateTime;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;
use validator::Validate;

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
}

#[derive(Insertable, Validate)]
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
}

#[derive(Serialize, Deserialize)]
pub struct TokenClaims {
	#[serde(rename = "userId")]
	pub user_id: i32,
	pub email: Option<String>,
	pub name: String,
	pub role: Role,
	pub exp: i64,
}

#[allow(dead_code)]
pub fn system_user() -> User {
	let created_at = NaiveDateTime::from_timestamp(1_000_000_000, 0);

	User {
		id: 0,
		created_at: created_at,
		email: Some("app@kicinv.co".to_owned()),
		client_id: 0,
		password_hash: "".to_owned(),
		name: "SYSTEM".to_owned(),
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
		}
	}

	impl UserAttrs {
		pub fn save(self, conn: &PgConnection) -> User {
			User::create(conn, self).unwrap()
		}

		pub fn email(mut self, email: Option<String>) -> Self {
			self.email = email;
			self
		}

		pub fn role(mut self, role: Role) -> Self {
			self.role = role;
			self
		}

		pub fn password_hash(mut self, ph: &str) -> Self {
			self.password_hash = ph.to_owned();
			self
		}

		pub fn email_confirmation_token(mut self, token: &str) -> Self {
			self.email_confirmation_token = Some(token.into());
			self
		}
	}

	impl User {
		pub fn delete_all(conn: &PgConnection) -> Result<usize, Error> {
			diesel::delete(users::table).execute(conn)
		}
	}
}
