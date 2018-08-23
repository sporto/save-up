#[macro_use]
extern crate diesel;
#[macro_use]
extern crate diesel_migrations;
#[macro_use]
extern crate failure;

extern crate aws_lambda as lambda;
extern crate url;

use failure::Error;
use lambda::event::apigw::{ApiGatewayProxyRequest,ApiGatewayProxyResponse};
use std::collections::HashMap;

mod db;
mod utils;

embed_migrations!();

fn main() {
	lambda::start(|request: ApiGatewayProxyRequest| {

		match run() {
			Ok(_) =>
				Ok(ApiGatewayProxyResponse {
					body: None,
					status_code: 200,
					headers: HashMap::new(),
					is_base64_encoded: None,
				}),
			Err(e) =>
				Ok(ApiGatewayProxyResponse {
					body: Some(e.to_string()),
					status_code: 500,
					headers: HashMap::new(),
					is_base64_encoded: None,
				}),
		}

	})
}

fn run() -> Result<(), Error> {
	let connection = db::establish_connection()?;

	embedded_migrations
		::run_with_output(&connection, &mut std::io::stdout())
		.map_err(|e| format_err!("{}", e.to_string()) )
}
