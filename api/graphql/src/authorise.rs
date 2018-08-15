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
extern crate chrono;
extern crate chrono_tz;
extern crate jsonwebtoken as jwt;
extern crate serde;
extern crate uuid;
extern crate validator;

use lambda::event::apigw::{
	ApiGatewayCustomAuthorizerPolicy, ApiGatewayCustomAuthorizerRequest,
	ApiGatewayCustomAuthorizerResponse, IamPolicyStatement,
};
use std::collections::HashMap;

mod db;
mod models;
mod services;
mod utils;

fn main() {
	lambda::start(|request: ApiGatewayCustomAuthorizerRequest| {
		let token = request
			.authorization_token
			.ok_or(format_err!("Failed to get authorization_token"))?;

		let token_data = services::users::decode_token::call(&token)?;

		let mut authorizerContext = HashMap::new();
		authorizerContext.insert("userId".to_string(), json!(token_data.user_id));

		let policy_document = ApiGatewayCustomAuthorizerPolicy {
			version: Some("2012-10-17".to_owned()),
			statement: vec![IamPolicyStatement {
				action: vec![],
				effect: Some("Allow".to_string()),
				resource: vec![],
			}],
		};

		// resource: vec![request.method_arn],
		// https://github.com/srijs/rust-aws-lambda/blob/739e46049651576e366fadd9073c2e269d11baa2/aws_lambda_events/src/generated/apigw.rs#L502
		let principal_id = format!("{}", token_data.user_id);

		let response = ApiGatewayCustomAuthorizerResponse {
			principal_id: Some(principal_id),
			policy_document: policy_document,
			context: authorizerContext,
			usage_identifier_key: None,
		};

		Ok(response)
	})
}
