#[macro_use]
extern crate failure;
extern crate rusoto_core;
extern crate rusoto_ses;
extern crate aws_lambda as lambda;

use lambda::event::apigw::{ApiGatewayProxyRequest, ApiGatewayProxyResponse};
use rusoto_core::Region;
use rusoto_ses::{SesClient,Ses,Destination,Message,SendEmailRequest, Body, Content};
use std::default::Default;
use std::time::Duration;
use failure::Error;
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

		let email = "sebasporto@gmail.com".to_string();
		let invitation_token = "abc".to_owned();
		send_email(&email, &invitation_token);

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

pub fn send_email(email: &str, invitation_token: &str) -> Result<(), Error> {

	let from = "hello@kidinv.co".to_owned();
	let to = vec!(email.clone().to_owned());
	let subject = "You have been invited".to_owned();
	let body_data = "You have been invited".to_owned();

	let client = SesClient::new(Region::ApSoutheast1);

	let body = Body {
		html: Some(Content {
			charset: Some(String::from("UTF-8")),
			data: body_data,
		}),
		text: None,
	};

	let message = Message {
		body: body,
		subject: Content {
			charset: Some(String::from("UTF-8")),
			data: subject,
		},
	};

	let mut email: SendEmailRequest = Default::default();

	email.source = from;

	email.destination = Destination {
		to_addresses: Some(to),
		bcc_addresses: None,
		cc_addresses: None,
	};

	email.message = message;

	client
		.send_email(email)
		.with_timeout(Duration::from_secs(20))
		.sync()
		.map_err(|_| format_err!("Failed to send email"))
		.map(|_response| ())
}
