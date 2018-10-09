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

extern crate actix;
extern crate actix_web;
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
extern crate rusoto_core;
extern crate rusoto_ses;
extern crate serde;
extern crate url;
extern crate uuid;
extern crate validator;

use actix::prelude::*;
use actix_web::{
	error, http, middleware, middleware::cors::Cors, server, App, AsyncResponder, Error,
	FutureResponse, HttpRequest, HttpResponse, Json, State,
};
use askama::Template;
// use diesel::prelude::*;
use futures::future::{result, Future};
use graph::{
	GraphQLAppExecutor, GraphQLPublicExecutor, ProcessAppGraphQlRequest,
	ProcessPublicGraphQlRequest,
};
use juniper::http::GraphQLRequest;

mod actions;
mod graph;
mod models;
mod utils;

#[derive(Template)]
#[template(path = "graphiql.html")]
struct GraphiqlTemplate;

struct AppState {
	db: Addr<DbExecutor>,
	executor_app: Addr<GraphQLAppExecutor>,
	executor_public: Addr<GraphQLPublicExecutor>,
}

pub struct DbExecutor(pub utils::db_conn::DBPool);

impl Actor for DbExecutor {
	type Context = SyncContext<Self>;
}

fn graphiql(_req: &HttpRequest<AppState>) -> Result<HttpResponse, Error> {
	GraphiqlTemplate
		.render()
		.map(|s| HttpResponse::Ok().content_type("text/html").body(s))
		.map_err(|askama_error| error::ErrorBadRequest(askama_error.to_string()))
}

fn graphql_public(
	(st, data): (State<AppState>, Json<GraphQLRequest>),
) -> FutureResponse<HttpResponse> {
	// We could use only one executor
	// If we can send here what context to use
	let msg = ProcessPublicGraphQlRequest { request: data.0 };

	st.executor_public
		.send(msg)
		.from_err()
		.and_then(|res| match res {
			Ok(response_data) => Ok(HttpResponse::Ok()
				.content_type("application/json")
				.body(response_data)),
			Err(_) => Ok(HttpResponse::InternalServerError().into()),
		}).responder()
}

fn get_token_from_request(request: &HttpRequest<AppState>) -> Result<String, failure::Error> {
	let header = request
		.headers()
		.get("Authorization")
		.ok_or("No Authorization header found")
		.map_err(|e| format_err!("{}", e))?;

	let txt = header.to_str()?;

	// Get the JWT from the header
	// e.g. Bearer abc123...
	// We don't need the Bearer part,
	// So get whatever is after an index of 7
	let token = &txt[7..];

	Ok(token.to_string())
}

fn graphql_app(
	(request, st, data): (HttpRequest<AppState>, State<AppState>, Json<GraphQLRequest>),
) -> FutureResponse<HttpResponse> {
	let unauthorised = HttpResponse::Unauthorized().finish();

	let token = match get_token_from_request(&request) {
		Ok(token) => token,
		Err(_) => return result(Ok(unauthorised)).responder(),
	};

	let msg = ProcessAppGraphQlRequest {
		token,
		request: data.0,
	};

	st.executor_app
		.send(msg)
		.from_err()
		.and_then(|res| match res {
			Ok(response_data) => Ok(HttpResponse::Ok()
				.content_type("application/json")
				.body(response_data)),
			Err(_) => Ok(HttpResponse::InternalServerError().into()),
		}).responder()
}

fn index(_req: &HttpRequest) -> &'static str {
	"Hello world!"
}

fn main() {
	askama::rerun_if_templates_changed();

	::std::env::set_var("RUST_LOG", "actix_web=info");
	env_logger::init();

	let config = utils::config::get().expect("Failed to get config");

	let sys = actix::System::new("juniper-example");

	let capacity = (num_cpus::get() / 2) as usize;

	// Start http server
	server::new(move || {
		// r2d2 db pool
		let pool = utils::db_conn::init_pool();

		let executor_app_addr = graph::create_app_executor(capacity, pool.clone());

		let executor_public_addr = graph::create_public_executor(capacity, pool.clone());

		let db_addr = SyncArbiter::start(capacity, move || DbExecutor(pool.clone()));

		let state = AppState {
			db: db_addr.clone(),
			executor_app: executor_app_addr.clone(),
			executor_public: executor_public_addr.clone(),
		};

		App::with_state(state)
            // enable logger
            .middleware(middleware::Logger::default())
			.configure(|app|
				Cors::for_app(app)
                    .allowed_origin(&config.client_host)
                    .allowed_methods(vec!["GET", "POST"])
                    .allowed_headers(vec![http::header::AUTHORIZATION, http::header::ACCEPT])
                    .allowed_header(http::header::CONTENT_TYPE)
                    .max_age(3600)
					.resource("/graphql-pub", |r| r.method(http::Method::POST).with(graphql_public))
					.resource("/graphql-app", |r| r.method(http::Method::POST).with(graphql_app))
					.resource("/graphiql", |r| r.method(http::Method::GET).h(graphiql))
                    .register()
			)
	}).bind("127.0.0.1:4010")
	.unwrap()
	.start();

	println!("Started http server: 127.0.0.1:4010");
	let _ = sys.run();
}
