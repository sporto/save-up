#[macro_use]
extern crate failure;
extern crate rusoto_core;
extern crate rusoto_ses;
extern crate aws_lambda as lambda;
#[macro_use]
extern crate tera;
#[macro_use]
extern crate lazy_static;

use lambda::event::sns::{SnsEvent};
use rusoto_core::Region;
use rusoto_ses::{SesClient,Ses,Destination,Message,SendEmailRequest, Body, Content};
use std::default::Default;
use std::time::Duration;
use failure::Error;
use std::collections::HashMap;
use tera::{Tera,Context};
use std::env;

lazy_static! {
	pub static ref TERA: Tera = {
		let mut tera = compile_templates!("templates/**/*");
		tera.autoescape_on(vec!["mjml"]);
		tera
	};
}

// https://github.com/srijs/rust-aws-lambda/blob/88904328b9f6a6ad016645a73a7acb41c08000cd/aws_lambda_events/src/generated/fixtures/example-sns-event.json
// https://github.com/srijs/rust-aws-lambda/blob/739e46049651576e366fadd9073c2e269d11baa2/aws_lambda_events/src/generated/sns.rs
fn main() {
	lambda::start(|event: SnsEvent| {
		let task = get_task(&event)?;

		let body = "Done".to_owned();

		let mut headers = HashMap::new();

		headers
			.insert(
				"Content-Type".to_owned(),
				"application/json".to_owned()
			); 

		let inviter = "Sam".to_string();
		let email = "sebasporto@gmail.com".to_string();
		let invitation_token = "abc".to_owned();

		send_email(&inviter, &email, &invitation_token)?;

		// Ok(
		// 	ApiGatewayProxyResponse {
		// 		body: Some(body),
		// 		status_code: 200,
		// 		headers: headers,
		// 		is_base64_encoded: None,
		// 	}
		// )
		Ok("Foo")
	})
}

enum Task {
	Invite { inviter: String, email: String, invitation_token: String }
}

fn get_task(event: &SnsEvent) -> Result<Task, Error> {
	let record = event.records.first()
		.ok_or(format_err!("Failed to get first record"))?;

	Ok(Task::Invite{
		inviter: "Sam".to_string(),
		email: "sebasporto@gmail.com".to_string(),
		invitation_token: "abc".to_owned(),
	})
}

// pub fn get_record(event: &SnsEvent) -> Result<SnsEventRecord, Error> {
// 	match events.records {
// 		[] => Err(format_err!("No record found")),
// 		r::xx => Ok(r),
// 	}
// }

fn send_email(inviter: &str, email: &str, invitation_token: &str) -> Result<(), Error> {

	let system_email = env::var("SYSTEM_EMAIL")
		.map_err(|_| format_err!("SYSTEM_EMAIL not found"))?;

	let mut context = Context::new();
	context.add("inviter", &inviter);
	context.add("invitation_token", &invitation_token);

	let from = system_email.to_owned();
	let to = vec!(email.clone().to_owned());
	let subject = "You have been invited".to_owned();

	let body_data = TERA.render("invite.html", &context)
		.map_err(|_| format_err!("Failed to render"))?;

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
