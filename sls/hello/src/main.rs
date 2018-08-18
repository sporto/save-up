extern crate aws_lambda as lambda;
use lambda::event::apigw::{ApiGatewayProxyRequest, ApiGatewayProxyResponse};

use std::collections::HashMap;

fn main() {
	lambda::start(|request: ApiGatewayProxyRequest| {
		let body = "Hello".to_owned();
		
		let mut headers = HashMap::new();

		headers
			.insert(
				"Content-Type".to_owned(),
				"application/json".to_owned()
			); 

		Ok(
			ApiGatewayProxyResponse {
				body: Some(body),
				status_code: 200,
				headers: headers,
				is_base64_encoded: None,
			}
		)
	})
}
