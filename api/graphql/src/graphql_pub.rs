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
extern crate rusoto_core;
extern crate rusoto_sns;
extern crate aws_lambda as lambda;
extern crate chrono_tz;
extern crate chrono;
extern crate jsonwebtoken as jwt;
extern crate libreauth;
extern crate serde;
extern crate uuid;
extern crate url;
extern crate validator;
extern crate shared;

// use diesel::pg::PgConnection;
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

const PUBLIC_PATH: &'static str = "/graphql-pub";
// const PRIVATE_PATH: &'static str = "/graphql";

type PublicSchema =
	RootNode<'static, graph::query_root::PublicQueryRoot, graph::mutation_root::PublicMutationRoot>;
type Schema = RootNode<'static, graph::query_root::QueryRoot, graph::mutation_root::MutationRoot>;

fn main() {
	lambda::start(|request: ApiGatewayProxyRequest| {
		let mut headers = HashMap::new();

		// TODO this shouldn't be here, needs to be in api gateway
		headers.insert("Access-Control-Allow-Origin".to_string(), "*".to_string());

		run(&request).map(|value| ApiGatewayProxyResponse {
			body: Some(value),
			status_code: 200,
			headers: headers,
			is_base64_encoded: None,
		})
	})
}

fn run(request: &ApiGatewayProxyRequest) -> Result<String, Error> {
	let conn = db::establish_connection()?;

	let context = graph::context::PublicContext { conn: conn };

	let query_root = graph::query_root::PublicQueryRoot {};

	let mutation_root = graph::mutation_root::PublicMutationRoot {};

	let schema = PublicSchema::new(query_root, mutation_root);

	let body = request.body.clone().ok_or(format_err!("Body not found"))?;

	let request: GraphQLRequest = serde_json::from_str(&body)?;

	let juniper_result = request.execute(&schema, &context);

	serde_json::to_string(&juniper_result).map_err(|e| format_err!("{}", e.to_string()))
}
