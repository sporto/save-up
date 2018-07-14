use super::schema::users;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;

#[derive(Queryable, GraphQLObject)]
pub struct User {
	pub id: i32,
	pub client_id: i32,
	pub role: String,
	pub name: String,
	pub email: String,
	pub encrypted_password: String,
	pub timezone: String,
}

#[derive(Insertable)]
#[table_name = "users"]
pub struct UserAttrs {
	pub client_id: i32,
	pub role: String,
	pub name: String,
	pub email: String,
	pub encrypted_password: String,
	pub timezone: String,
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

	// Delete
	pub fn delete_all(conn: &PgConnection) -> Result<usize, Error> {
		diesel::delete(users::table).execute(conn)
	}
}
