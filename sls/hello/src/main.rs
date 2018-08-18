extern crate aws_lambda as lambda;
use lambda::event::apigw::{ApiGatewayProxyRequest, ApiGatewayProxyResponse};

use std::collections::HashMap;

fn main() {
	lambda::start(|request: ApiGatewayProxyRequest| {
		Ok(
			ApiGatewayProxyResponse {
				body: Some("Hello".to_owned()),
				status_code: 200,
				headers: HashMap::new(),
				is_base64_encoded: None,
			}
		)
	})
}
