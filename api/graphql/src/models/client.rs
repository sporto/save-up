use super::schema::clients;
use chrono::NaiveDateTime;
use diesel;
use diesel::prelude::*;
use diesel::result::Error;

use diesel::pg::PgConnection;

#[allow(dead_code)]
const RESOURCE_KIND: &'static str = "client";

#[derive(Insertable)]
#[table_name = "clients"]
pub struct ClientAttrs {
	pub name: String,
}

#[derive(Queryable, GraphQLObject)]
pub struct Client {
	pub id: i32,
	pub created_at: NaiveDateTime,
	pub name: String,
}

impl Client {
	// Create
	pub fn create(conn: &PgConnection, attrs: ClientAttrs) -> Result<Client, Error> {
		diesel::insert_into(clients::dsl::clients)
			.values(&attrs)
			.get_result(conn)
	}

	// Read
	#[allow(dead_code)]
	pub fn all(conn: &PgConnection) -> Vec<Client> {
		clients::table
			.load::<Client>(conn)
			.expect("Error loading clients")
	}

	#[allow(dead_code)]
	pub fn find(conn: &PgConnection, client_id: i32) -> Result<Client, Error> {
		clients::table.find(client_id).first::<Client>(conn)
	}

	pub fn first(conn: &PgConnection) -> Result<Client, Error> {
		clients::table.first::<Client>(conn)
	}

	// Delete
	#[allow(dead_code)]
	pub fn delete_all(conn: &PgConnection) -> Result<usize, Error> {
		diesel::delete(clients::table).execute(conn)
	}
}

#[cfg(test)]
pub mod factories {
	use super::*;

	pub fn client_attrs() -> ClientAttrs {
		ClientAttrs {
			name: "Client".to_owned(),
		}
	}

	impl ClientAttrs {
		pub fn save(self, conn: &PgConnection) -> Client {
			Client::create(conn, self).unwrap()
		}
	}
}
