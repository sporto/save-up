#![feature(proc_macro_hygiene, decl_macro)]

extern crate askama;
#[macro_use]
extern crate diesel;
#[macro_use]
extern crate diesel_migrations;
#[macro_use]
extern crate failure;
#[macro_use]
extern crate juniper;
#[macro_use]
extern crate serde_derive;
#[macro_use]
extern crate serde_json;
#[macro_use]
extern crate validator_derive;
#[macro_use]
extern crate lazy_static;
#[macro_use]
extern crate rocket;
#[macro_use]
extern crate rocket_contrib;
#[macro_use]
extern crate log;
extern crate env_logger;

use rocket::{
	config::{Config, Environment, Value},
	fairing::AdHoc,
	http::{Method, Status},
	outcome,
	request::{self, FromRequest, Request},
	Rocket, State,
};
use std::collections::HashMap;

use rocket_cors::{AllowedHeaders, AllowedOrigins};

mod actions;
mod graph;
mod models;
mod utils;

embed_migrations!();

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

#[database("postgres")]
struct DbConn(diesel::PgConnection);

#[get("/status")]
fn index() -> &'static str {
	"Ok"
}

#[get("/email")]
fn send_email()->  Result<String, String> {
	actions::emails::send_test::call()
		.map(|_| "Ok".to_string() )
		.map_err(|e| e.to_string())
}

#[post("/app/graphql", data = "<request>")]
fn graphql_app_handler(
	jwt: JWT,
	request: juniper_rocket::GraphQLRequest,
	schema: State<graph::AppSchema>,
	conn: DbConn,
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

#[post("/pub/graphql", data = "<request>")]
fn graphql_pub_handler(
	request: juniper_rocket::GraphQLRequest,
	schema: State<graph::PublicSchema>,
	conn: DbConn,
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

fn run_migrations(rocket: Rocket) -> Result<Rocket, Rocket> {
	let conn = DbConn::get_one(&rocket).expect("database connection");
	match embedded_migrations::run_with_output(&conn.0, &mut std::io::stdout()) {
		Ok(()) => Ok(rocket),
		Err(e) => {
			error!("Failed to run database migrations: {:?}", e);
			Err(rocket)
		},
	}
}

fn rocket() -> Result<Rocket, failure::Error> {
	let config = utils::config::get().expect("Failed to get config");

	let mut database_config = HashMap::new();
	let mut databases = HashMap::new();

	database_config.insert("url", Value::from(config.database_url));
	databases.insert("postgres", Value::from(database_config));

	let rocket_config = Config::build(Environment::Staging)
		.address("0.0.0.0")
		.port(config.api_port)
		.extra("template_dir", "templates/")
		.extra("databases", databases)
		.finalize()
		.expect("Failed to create rocket config");

	// CORS
	// let (allowed_origins, failed_origins) = AllowedOrigins::some(&[&config.client_host]);

	let allowed_origins = AllowedOrigins::some_exact(&[&config.client_host]);

	// assert!(failed_origins.is_empty());

	let allowed_methods = vec![Method::Get, Method::Post]
		.into_iter()
		.map(From::from)
		.collect();

	let allowed_headers = AllowedHeaders::some(&["Authorization", "Accept", "content-type"]);

	let options = rocket_cors::CorsOptions {
		allowed_origins: allowed_origins,
		allowed_methods: allowed_methods,
		allowed_headers: allowed_headers,
		allow_credentials: true,
		..Default::default()
	}.to_cors()?;

	let routes = routes![index, send_email, graphql_app_handler, graphql_pub_handler,];

	let schema_app = graph::create_app_schema();
	let schema_pub = graph::create_public_schema();

	let ro = rocket::custom(rocket_config)
		.attach(DbConn::fairing())
		.attach(AdHoc::on_attach("Database Migrations", run_migrations))
		.manage(schema_app)
		.manage(schema_pub)
		.mount("/", routes)
		.attach(options);

	Ok(ro)
}

fn main() {
	env_logger::init();

	rocket()
		.map(|ro| ro.launch());
}
