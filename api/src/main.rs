#![feature(plugin)]
#![plugin(rocket_codegen)]

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
extern crate juniper_rocket;
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
use rocket::http::{Method, Status};
use rocket::outcome;
use rocket::request::{self, FromRequest, Request};
use rocket::response::content;
use rocket::response::NamedFile;
use rocket::Rocket;
use rocket::State;
use rocket_cors::{AllowedHeaders, AllowedOrigins};

mod actions;
mod graph;
mod models;
mod utils;

// #[derive(Template)]
// #[template(path = "graphiql.html")]
// struct GraphiqlTemplate;

struct JWT(String);

impl<'a, 'r> FromRequest<'a, 'r> for JWT {
	type Error = ();

	fn from_request(request: &'a Request<'r>) -> request::Outcome<JWT, ()> {
		match get_token_from_request(request) {
			Ok(token) => outcome::Outcome::Success(JWT(token)),
			Err(_e) => outcome::Outcome::Failure((Status::Unauthorized, ())),
		}

		// let keys: Vec<_> = request.headers().get("x-api-key").collect();
		// if keys.len() != 1 {
		// 	return Outcome::Failure((Status::BadRequest, ()));
		// }

		// let key = keys[0];
		// if !is_valid(keys[0]) {
		// 	return Outcome::Forward(());
		// }

		// return Outcome::Success(ApiKey(key.to_string()));
	}
}

// impl<'a, 'r> FromRequest<'a, 'r> for User {
// 	type Error = ();

// 	fn from_request(request: &'a Request<'r>) -> request::Outcome<User, ()> {
// 		let jwt = req.guard::<State<JWT>>()?;
// 		let current_count = hit_count_state.count.load(Ordering::Relaxed);
// 	}
// }

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
		Err(_) => {
			return juniper_rocket::GraphQLResponse(Status::Unauthorized, "Unauthorized".to_string())
		}
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

// impl<'a, 'r> FromRequest<'a, 'r> for models::user::User {
// 	type Error = ();

// 	fn from_request(
// 		request: &'a Request<'r>,
// 		pool: utils::db_conn::DBConn,
// 	) -> request::Outcome<graph::AppContext, ()> {
// 		get_token_from_request(request)
// 			.and_then(|token| {
// 				let conn = pool.get().unwrap();
// 				actions::users::get_user::call(&conn, &token)
// 			}).into_outcome((Status::Unauthorized, ()))
// 	}
// }

// impl<'a, 'r> FromRequest<'a, 'r> for graph::AppContext {
// 	type Error = ();

// 	fn from_request(
// 		request: &'a Request<'r>,
// 		user: models::user::User,
// 		pool: utils::db_conn::DBConn,
// 	) -> request::Outcome<graph::AppContext, ()> {
// 		let context_app = graph::AppContext {
// 			pool: pool,
// 			user: user,
// 		};

// 		request::Outcome::Success(context_app)
// 	}
// }

fn get_token_from_request(request: &Request) -> Result<String, failure::Error> {
	let keys: Vec<_> = request.headers().get("Authorization").collect();

	let txt = keys
		.first()
		.ok_or(format_err!("No Authorization header found"))?;

	// if keys.len() != 1 {
	// 	return Outcome::Failure((Status::BadRequest, ()));
	// }

	// let key = keys[0];
	// if !is_valid(keys[0]) {
	// 	return Outcome::Forward(());
	// }

	// let header = request
	// 	.headers()
	// 	.get("Authorization")
	// 	.ok_or("No Authorization header found")
	// 	.map_err(|e| format_err!("{}", e))?;

	// let txt = header.to_str()?;

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
