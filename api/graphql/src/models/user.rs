use super::schema::users;
use chrono::NaiveDateTime;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;
use validator::Validate;

pub const ROLE_ADMIN: &str = "admin";
#[allow(dead_code)]
pub const ROLE_INVESTOR: &str = "investor";

#[derive(Queryable, GraphQLObject, Debug, Clone)]
pub struct User {
	pub id: i32,
	pub created_at: NaiveDateTime,
	pub client_id: i32,
	pub email: String,
	pub password_hash: String,
	pub name: String,
	pub role: String,
	pub email_confirmation_token: Option<String>,
	pub email_confirmed_at: Option<NaiveDateTime>,
}

#[derive(Insertable, Validate)]
#[table_name = "users"]
pub struct UserAttrs {
	pub client_id: i32,
	#[validate(email)]
	pub email: String,
	pub password_hash: String,
	#[validate(length(min = "1"))]
	pub name: String,
	pub role: String,
	pub email_confirmation_token: Option<String>,
	pub email_confirmed_at: Option<NaiveDateTime>,
}

#[derive(Serialize, Deserialize)]
pub struct TokenData {
	#[serde(rename = "userId")]
	pub user_id: i32,
	pub email: String,
	pub name: String,
	pub role: String,
}

#[cfg(test)]
use models::client::Client;

#[cfg(test)]
pub fn user_attrs(client: &Client) -> UserAttrs {
	UserAttrs {
		client_id: client.id,
		email: "sam@sample.com".to_owned(),
		password_hash: "abc".to_owned(),
		name: "Sam".to_owned(),
		role: ROLE_ADMIN.to_owned(),
		email_confirmation_token: None,
		email_confirmed_at: None,
	}
}

pub fn system_user() -> User {
	let created_at = NaiveDateTime::from_timestamp(1_000_000_000, 0);

	User {
		id: 0,
		created_at: created_at,
		email: "app@kicinv.co".to_owned(),
		client_id: 0,
		password_hash: "".to_owned(),
		name: "SYSTEM".to_owned(),
		role: ROLE_ADMIN.to_owned(),
		email_confirmation_token: None,
		email_confirmed_at: None,
	}
}

#[cfg(test)]
impl UserAttrs {
	pub fn save(self, conn: &PgConnection) -> User {
		User::create(conn, self).unwrap()
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
	// Create
	pub fn create(conn: &PgConnection, attrs: UserAttrs) -> Result<User, Error> {
		diesel::insert_into(users::dsl::users)
			.values(&attrs)
			.get_results(conn)
			.and_then(|mut users| users.pop().ok_or(Error::NotFound))
	}

	// Read
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
			.limit(1)
			.first::<User>(conn)
	}

	// Delete
	#[allow(dead_code)]
	pub fn delete_all(conn: &PgConnection) -> Result<usize, Error> {
		diesel::delete(users::table).execute(conn)
	}
}
