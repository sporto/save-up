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
extern crate chrono_tz;
extern crate chrono;
extern crate jsonwebtoken as jwt;
extern crate libreauth;
extern crate serde;
extern crate uuid;
extern crate url;
extern crate validator;

use diesel::pg::PgConnection;
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

#[derive(Serialize, Deserialize)]
struct Query {
	query: String,
	age: u8,
	phones: Vec<String>,
}

fn run(request: &ApiGatewayProxyRequest) -> Result<String, Error> {
	match request.resource {
		Some(ref path) => {
			if path == PUBLIC_PATH {
				run_public(request)
			} else {
				run_private(request)
			}
		}
		_ => Err(format_err!("Unknown resource path")),
	}
}

fn run_public(request: &ApiGatewayProxyRequest) -> Result<String, Error> {
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

fn run_private(request: &ApiGatewayProxyRequest) -> Result<String, Error> {
	// We are supposed to use a lambda function as authoriser
	// But SAM doesn't support this flow when working locally yet
	// So I don't know how to wire this
	// For now do all the work here

	// Get user id
	// let user_id_val = request
	// 	.request_context
	// 	.authorizer
	// 	.get("userId")
	// 	.ok_or(format_err!("Failed to get userId"))?;

	// let user_id = user_id_val
	// 	.as_i64()
	// 	.ok_or(format_err!("Failed to parse {}", user_id_val))
	// 	.map(|n| n as i32)?;

	// Find the authorisation header
	let header = request
		.headers
		.get("Authorization")
		.ok_or(format_err!("No Authorization header found"))?;

	// Get the jwt from the header
	// e.g. Bearer abc123...
	// We don't need the Bearer part,
	// So get whatever is after an index of 7
	let token = &header[7..];

	let conn = db::establish_connection()?;

	let user = get_user(&conn, token)?;

	let context = graph::context::Context {
		conn: conn,
		user: user,
	};

	let query_root = graph::query_root::QueryRoot {};

	let mutation_root = graph::mutation_root::MutationRoot {};

	let schema = Schema::new(query_root, mutation_root);

	let body = request.body.clone().ok_or(format_err!("Body not found"))?;

	let request: GraphQLRequest = serde_json::from_str(&body)?;

	let juniper_result = request.execute(&schema, &context);

	serde_json::to_string(&juniper_result).map_err(|e| format_err!("{}", e.to_string()))
}

fn get_user(conn: &PgConnection, token: &str) -> Result<models::users::User, Error> {
	let config = utils::config::get()?;

	if token == config.system_jwt {
		return Ok(models::users::system_user());
	}

	let token_data = services::users::decode_token::call(token)?;

	let user_id = token_data.user_id;

	models::users::User::find(&conn, user_id)
		.map_err(|_| format_err!("User not found"))
}
