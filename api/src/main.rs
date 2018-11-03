#![feature(proc_macro_hygiene, decl_macro)]
#![feature(custom_derive)]

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

extern crate bigdecimal;
extern crate chrono;
extern crate chrono_tz;
extern crate env_logger;
extern crate futures;
extern crate jsonwebtoken as jwt;
extern crate libreauth;
extern crate num_cpus;
extern crate r2d2;
extern crate range_check;
extern crate regex;
extern crate rocket_cors;
extern crate rusoto_core;
extern crate rusoto_ses;
extern crate serde;
extern crate url;
extern crate uuid;
extern crate validator;

// use askama::Template;
use rocket::http::Method;
use rocket::response::content;
use rocket::response::NamedFile;
use rocket::Rocket;
use rocket::State;
use rocket_cors::{AllowedHeaders, AllowedOrigins};

mod actions;
mod graph;
mod juniper_rocket;
mod models;
mod utils;

// #[derive(Template)]
// #[template(path = "graphiql.html")]
// struct GraphiqlTemplate;

#[get("/")]
fn index() -> &'static str {
	"Hello, world!"
}

#[post("/graphql-pub", data = "<request>")]
fn graphql_pub_handler(
	context: State<graph::PublicContext>,
	request: juniper_rocket::GraphQLRequest,
	schema: State<graph::PublicSchema>,
) -> juniper_rocket::GraphQLResponse {
	request.execute(&schema, &context)
}

fn rocket() -> Rocket {
	let config = utils::config::get();

	let pool = utils::db_conn::init_pool();
	// let query_root = graph::query_root::QueryRoot {};
	// let mutation_root = graph::mutation_root::MutationRoot {};

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

	let routes = routes![
		index,
		// handlers::root,
		// handlers::status,
		// handlers::sign_up,
		// handlers::sign_in,
		// graphiql,
		// graphql_pub_handler,
		// post_graphql_handler,
	];

	let schema_pub = graph::create_public_schema;

	let context_pub = graph::PublicContext { conn: pool };

	rocket::ignite()
		.manage(pool.clone())
		.manage(context_pub)
		.manage(schema_pub)
		.mount("/", routes)
		.attach(options)
}

fn main() {
	// rocket::ignite().mount("/", routes![index]).launch();
	rocket().launch();
}
