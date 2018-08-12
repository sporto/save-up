use super::schema::users;
use chrono::{NaiveDateTime};
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;
use validator::Validate;

pub const ROLE_ADMIN: &str = "admin";
#[allow(dead_code)]
pub const ROLE_INVESTOR: &str = "investor";

#[derive(Queryable, GraphQLObject, Debug)]
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

#[derive(Serialize,Deserialize)]
pub struct TokenData {
	pub user_id: i32,
	pub email: String,
	pub name: String,
	pub role: String,
}

#[cfg(test)]
use models::clients::Client;

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

impl UserAttrs {
	pub fn save(self, conn: &PgConnection) -> User {
		User::create(conn, self).unwrap()
	}

	pub fn password_hash(mut self, ph: &str) -> Self {
		self.password_hash = ph.to_owned();
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
