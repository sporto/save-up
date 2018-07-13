use super::schema::clients;
use diesel;
use diesel::prelude::*;
use diesel::result::Error;
use utils::ids::{hash_id, unhash_id};

use diesel::pg::PgConnection;

#[allow(dead_code)]
const RESOURCE_KIND: &'static str = "client";

#[derive(Queryable, GraphQLObject)]
pub struct Client {
	pub id: i32,
	pub name: String,
}

#[derive(Insertable)]
#[table_name = "clients"]
pub struct ClientAttrs {
	pub name: String,
}

impl Client {
	#[allow(dead_code)]
	pub fn hash_id(id: i32) -> String {
		hash_id(id, RESOURCE_KIND)
	}

	#[allow(dead_code)]
	pub fn unhash_id(id: &str) -> i32 {
		unhash_id(id, RESOURCE_KIND)
	}

	// Create
	#[allow(dead_code)]
	pub fn add(conn: &PgConnection, attrs: ClientAttrs) -> Result<Client, Error> {
		diesel::insert_into(clients::dsl::clients)
			.values(&attrs)
			.get_results(conn)
			.and_then(|mut clients| clients.pop().ok_or(Error::NotFound))
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
		// clients::table.filter(clients::id.eq(client_id))
		//     .limit(1)
		//     .load::<Client>(conn)
		//     .and_then(|mut clients| clients.pop().ok_or(Error::NotFound))
		clients::table.find(client_id).first::<Client>(conn)
	}

	pub fn first(conn: &PgConnection) -> Result<Client, Error> {
		clients::table
			.limit(1)
			.load::<Client>(conn)
			.and_then(|mut clients| clients.pop().ok_or(Error::NotFound))
	}

	// Delete
	pub fn delete_all(conn: &PgConnection) -> Result<usize, Error> {
		diesel::delete(clients::table).execute(conn)
	}
}
