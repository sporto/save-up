use super::schema::users;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;
use validator::Validate;

pub const ROLE_ADMIN: &str = "admin";
pub const ROLE_INVESTOR: &str = "investor";

#[derive(Queryable, GraphQLObject, Debug)]
pub struct User {
	pub id: i32,
	pub client_id: i32,
	pub role: String,
	pub name: String,
	pub email: String,
	pub password_hash: String,
	pub timezone: String,
}

#[derive(Insertable, Validate)]
#[table_name = "users"]
pub struct UserAttrs {
	pub client_id: i32,
	pub role: String,
	#[validate(length(min = "1"))]
	pub name: String,
	#[validate(email)]
	pub email: String,
	pub password_hash: String,
	pub timezone: String,
}

#[allow(dead_code)]
pub fn new_user() -> User {
	User {
		id: 1,
		client_id: 2,
		role: ROLE_ADMIN.to_owned(),
		name: "Sam".to_owned(),
		email: "sam@sample.com".to_owned(),
		password_hash: "".to_owned(),
		timezone: "Australia/Melbourne".to_owned(),
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
