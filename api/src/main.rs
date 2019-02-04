#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use]
extern crate askama;
#[macro_use]
extern crate diesel;
extern crate diesel_migrations;
#[macro_use]
extern crate failure;
#[macro_use]
extern crate juniper;
#[macro_use]
extern crate serde_derive;
extern crate serde_json;
#[macro_use]
extern crate validator_derive;
#[macro_use]
extern crate lazy_static;
#[macro_use]
extern crate rocket;

use rocket::{
	http::{Method, Status},
	outcome,
	request::{self, FromRequest, Request},
};

use rocket::{Rocket, State};
use rocket_cors::{AllowedHeaders, AllowedOrigins};

mod actions;
mod graph;
mod models;
mod utils;

struct JWT(String);

impl<'a, 'r> FromRequest<'a, 'r> for JWT {
	type Error = ();

	fn from_request(request: &'a Request<'r>) -> request::Outcome<JWT, ()> {
		// println!("Get JWT");

		match get_token_from_request(request) {
			Ok(token) => {
				// println!("Ok token {}", token);
				outcome::Outcome::Success(JWT(token))
			},
			Err(e) => {
				println!("{}", e.to_string());
				outcome::Outcome::Failure((Status::Unauthorized, ()))
			},
		}
	}
}

#[get("/")]
fn index() -> &'static str {
	"Hello"
}

#[post("/graphql-app", data = "<request>")]
fn graphql_app_handler(
	jwt: JWT,
	request: juniper_rocket::GraphQLRequest,
	schema: State<graph::AppSchema>,
	conn: utils::db_conn::DBConn,
) -> juniper_rocket::GraphQLResponse {
	// let conn = pool.get().unwrap();
	let JWT(token) = jwt;

	let user = match actions::users::get_user::call(&conn, &token) {
		Ok(user) => user,
		Err(e) => return juniper_rocket::GraphQLResponse(Status::Unauthorized, e.to_string()),
	};

	let context = graph::AppContext {
		conn: conn.0,
		user: user,
	};

	request.execute(&schema, &context)
}

#[post("/graphql-pub", data = "<request>")]
fn graphql_pub_handler(
	request: juniper_rocket::GraphQLRequest,
	schema: State<graph::PublicSchema>,
	conn: utils::db_conn::DBConn,
) -> juniper_rocket::GraphQLResponse {
	let context = graph::PublicContext { conn: conn.0 };

	request.execute(&schema, &context)
}

fn get_token_from_request(request: &Request) -> Result<String, failure::Error> {
	let keys: Vec<_> = request.headers().get("Authorization").collect();

	let txt = keys
		.first()
		.ok_or(format_err!("No Authorization header found"))?;

	// Get the JWT from the header
	// e.g. Bearer abc123...
	// We don't need the Bearer part,
	// So get whatever is after an index of 7
	let token = &txt[7..];

	Ok(token.to_string())
}

fn rocket() -> Rocket {
	let config = utils::config::get().expect("Failed to get config");

	// CORS
	let (allowed_origins, failed_origins) = AllowedOrigins::some(&[&config.client_host]);

	assert!(failed_origins.is_empty());

	let allowed_methods = vec![Method::Get, Method::Post]
		.into_iter()
		.map(From::from)
		.collect();

	let allowed_headers = AllowedHeaders::some(&["Authorization", "Accept", "content-type"]);

	let options = rocket_cors::Cors {
		allowed_origins: allowed_origins,
		allowed_methods: allowed_methods,
		allowed_headers: allowed_headers,
		allow_credentials: true,
		..Default::default()
	};

	let routes = routes![index, graphql_app_handler, graphql_pub_handler,];

	let pool = utils::db_conn::init_pool();

	let schema_app = graph::create_app_schema();
	let schema_pub = graph::create_public_schema();

	// log::info!("Starting");

	rocket::ignite()
		.manage(pool.clone())
		.manage(schema_app)
		.manage(schema_pub)
		.mount("/", routes)
		.attach(options)
}

fn main() {
	rocket().launch();
}
