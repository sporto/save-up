#[macro_use]
extern crate diesel;
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

extern crate aws_lambda as lambda;
extern crate bcrypt;
extern crate chrono_tz;
extern crate chrono;
extern crate frank_jwt;
extern crate serde;
extern crate uuid;
extern crate validator;

use failure::Error;
use juniper::http::GraphQLRequest;
use juniper::RootNode;
use lambda::event::apigw::{ApiGatewayProxyRequest, ApiGatewayProxyResponse};
use std::collections::HashMap;

mod db;
mod graph;
mod models;
mod services;
mod utils;

type Schema = RootNode<'static, graph::query_root::QueryRoot, graph::mutation_root::MutationRoot>;

fn main() {
	lambda::start(|request: ApiGatewayProxyRequest| {
		let mut headers = HashMap::new();

		// TODO this shouldn't be here, needs to be in api gateway
		headers.insert("Access-Control-Allow-Origin".to_string(), "*".to_string());

		run(request).map(|value| ApiGatewayProxyResponse {
			body: Some(value),
			status_code: 200,
			headers: headers,
			is_base64_encoded: None,
		})
	})
}

#[derive(Serialize, Deserialize)]
struct Query {
	query: String,
	age: u8,
	phones: Vec<String>,
}

fn run(request: ApiGatewayProxyRequest) -> Result<String, Error> {
	let conn = db::establish_connection()?;

	let context = graph::query_root::Context { conn: conn };

	let query_root = graph::query_root::QueryRoot {};

	let mutation_root = graph::mutation_root::MutationRoot {};

	let schema = Schema::new(query_root, mutation_root);

	let body = request.body.ok_or(format_err!("Body not found"))?;

	let request: GraphQLRequest = serde_json::from_str(&body)?;

	let juniper_result = request.execute(&schema, &context);

	serde_json::to_string(&juniper_result).map_err(|e| format_err!("{}", e.to_string()))
}
