use super::schema::clients;
use chrono::NaiveDateTime;
use diesel;
use diesel::prelude::*;
use diesel::result::Error;

use diesel::pg::PgConnection;

#[allow(dead_code)]
const RESOURCE_KIND: &'static str = "client";

#[derive(Queryable, Identifiable, GraphQLObject)]
#[table_name = "clients"]
pub struct Client {
	pub id: i32,
	pub created_at: NaiveDateTime,
	pub name: String,
}

#[derive(Insertable)]
#[table_name = "clients"]
pub struct ClientAttrs {
	pub name: String,
}

impl Client {
	// Create
	#[allow(dead_code)]
	pub fn create(conn: &PgConnection, attrs: ClientAttrs) -> Result<Client, Error> {
		diesel::insert_into(clients::dsl::clients)
			.values(&attrs)
			.get_result(conn)
	}

	// Read
	// #[allow(dead_code)]
	// pub fn all(conn: &PgConnection) -> Vec<Client> {
	// 	clients::table
	// 		.load::<Client>(conn)
	// 		.expect("Error loading clients")
	// }

	#[allow(dead_code)]
	pub fn find(conn: &PgConnection, client_id: i32) -> Result<Client, Error> {
		clients::table.find(client_id).first::<Client>(conn)
	}

	#[allow(dead_code)]
	pub fn first(conn: &PgConnection) -> Result<Client, Error> {
		clients::table.first::<Client>(conn)
	}
}

#[cfg(test)]
pub mod factories {
	use super::*;

	#[allow(dead_code)]
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

	impl Client {
		pub fn delete_all(conn: &PgConnection) -> Result<usize, Error> {
			diesel::delete(clients::table).execute(conn)
		}
	}
}
