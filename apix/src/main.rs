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

extern crate actix;
extern crate actix_web;
extern crate bigdecimal;
extern crate chrono;
extern crate chrono_tz;
extern crate env_logger;
extern crate futures;
extern crate jsonwebtoken as jwt;
extern crate libreauth;
extern crate range_check;
extern crate regex;
extern crate rusoto_core;
extern crate rusoto_sns;
extern crate serde;
extern crate url;
extern crate uuid;
extern crate validator;

use actix::prelude::*;
use actix_web::{
	http, middleware, server, App, AsyncResponder, Error, FutureResponse, HttpRequest,
	HttpResponse, Json, State,
};
// use diesel::pg::PgConnection;
// use failure::Error;
use futures::future::Future;
use juniper::http::graphiql::graphiql_source;
use juniper::http::GraphQLRequest;
// use juniper::RootNode;
use schema::{create_schema, Schema};
// use std::collections::HashMap;

mod actions;
mod app;
mod models;
mod public;
mod schema;
mod utils;

struct AppState {
	executor: Addr<GraphQLExecutor>,
}

#[derive(Serialize, Deserialize)]
pub struct GraphQLData(GraphQLRequest);

impl Message for GraphQLData {
	type Result = Result<String, Error>;
}

pub struct GraphQLExecutor {
	schema: std::sync::Arc<Schema>,
}

impl GraphQLExecutor {
	fn new(schema: std::sync::Arc<Schema>) -> GraphQLExecutor {
		GraphQLExecutor { schema: schema }
	}
}

impl Actor for GraphQLExecutor {
	type Context = SyncContext<Self>;
}

impl Handler<GraphQLData> for GraphQLExecutor {
	type Result = Result<String, Error>;

	fn handle(&mut self, msg: GraphQLData, _: &mut Self::Context) -> Self::Result {
		let res = msg.0.execute(&self.schema, &());
		let res_text = serde_json::to_string(&res)?;
		Ok(res_text)
	}
}

fn graphiql(_req: &HttpRequest<AppState>) -> Result<HttpResponse, Error> {
	let html = graphiql_source("http://127.0.0.1:8080/graphql");
	Ok(HttpResponse::Ok()
		.content_type("text/html; charset=utf-8")
		.body(html))
}

fn graphql((st, data): (State<AppState>, Json<GraphQLData>)) -> FutureResponse<HttpResponse> {
	st.executor
		.send(data.0)
		.from_err()
		.and_then(|res| match res {
			Ok(user) => Ok(HttpResponse::Ok()
				.content_type("application/json")
				.body(user)),
			Err(_) => Ok(HttpResponse::InternalServerError().into()),
		}).responder()
}

fn index(_req: &HttpRequest) -> &'static str {
	"Hello world!"
}

fn main() {
	::std::env::set_var("RUST_LOG", "actix_web=info");
	env_logger::init();
	let sys = actix::System::new("juniper-example");

	let schema = std::sync::Arc::new(create_schema());
	let addr = SyncArbiter::start(3, move || GraphQLExecutor::new(schema.clone()));

	// Start http server
	server::new(move || {
		App::with_state(AppState{executor: addr.clone()})
            // enable logger
            .middleware(middleware::Logger::default())
            .resource("/graphql", |r| r.method(http::Method::POST).with(graphql))
            .resource("/graphiql", |r| r.method(http::Method::GET).h(graphiql))
	}).bind("127.0.0.1:4010")
	.unwrap()
	.start();

	println!("Started http server: 127.0.0.1:4010");
	let _ = sys.run();
}
