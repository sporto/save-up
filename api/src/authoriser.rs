#[macro_use]
extern crate serde_json;

extern crate aws_lambda as lambda;
use lambda::event::apigw::{ApiGatewayCustomAuthorizerRequest, ApiGatewayCustomAuthorizerResponse, ApiGatewayCustomAuthorizerPolicy, IamPolicyStatement};
use std::collections::HashMap;

fn main() {
	lambda::start(|request: ApiGatewayCustomAuthorizerRequest| {

		let policy = ApiGatewayCustomAuthorizerPolicy {
			version: Some("2012-10-17".to_owned()),
			statement: vec![
				IamPolicyStatement {
					action: vec![],
					effect: None,
          			resource: vec![],
				}
			]
		};

		let mut context = HashMap::new();
		context.insert("userId".to_owned(), json!(1));

		let response = ApiGatewayCustomAuthorizerResponse {
			principal_id: None,
			policy_document: policy,
			context: context,
			usage_identifier_key: None,
		};

		Ok(response)
	})
}
