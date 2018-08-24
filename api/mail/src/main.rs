#[macro_use]
extern crate failure;
extern crate aws_lambda as lambda;
extern crate chrono;
extern crate rusoto_core;
extern crate rusoto_ses;
extern crate serde;
extern crate serde_json;
#[macro_use]
extern crate askama;
extern crate openssl_probe;
extern crate shared;

use askama::Template;
use failure::Error;
use lambda::event::sns::SnsEvent;
use rusoto_core::Region;
use rusoto_ses::{Body, Content, Destination, Message, SendEmailRequest, Ses, SesClient};
use shared::email_kinds::EmailKind;
use std::default::Default;
use std::env;
use std::time::Duration;

#[derive(Template)]
#[template(path = "invite.html")]
struct InviteTemplate<'a> {
	inviter: &'a str,
	invitation_token: &'a str,
}

#[derive(Template)]
#[template(path = "confirm_email.html")]
struct ConfirmEmailTemplate<'a> {
	confirmation_token: &'a str,
}

// https://github.com/srijs/rust-aws-lambda/blob/88904328b9f6a6ad016645a73a7acb41c08000cd/aws_lambda_events/src/generated/fixtures/example-sns-event.json
// https://github.com/srijs/rust-aws-lambda/blob/739e46049651576e366fadd9073c2e269d11baa2/aws_lambda_events/src/generated/sns.rs
fn main() {
	openssl_probe::init_ssl_cert_env_vars();

	lambda::start(|event: SnsEvent| {
		let email_kind = get_email_kind(&event)?;

		generate_intermidiate(&email_kind)
			.and_then(|intermediate| generate_html(&intermediate))
			.and_then(|html| send_email(&email_kind, &html))?;

		Ok("Success")
	})
}

fn get_email_kind(event: &SnsEvent) -> Result<EmailKind, Error> {
	let record = event
		.records
		.first()
		.ok_or(format_err!("Failed to get first record"))?;

	let message = record
		.clone()
		.sns
		.message
		.ok_or(format_err!("No message found"))?;

	let email_kind: EmailKind = serde_json::from_str(&message)?;

	Ok(email_kind)
}

fn generate_intermidiate(email_kind: &EmailKind) -> Result<String, Error> {
	let result = match email_kind {
		EmailKind::ConfirmEmail {
			confirmation_token, ..
		} => ConfirmEmailTemplate {
			confirmation_token: confirmation_token,
		}.render(),

		EmailKind::Invite {
			inviter,
			invitation_token,
			..
		} => InviteTemplate {
			inviter: inviter,
			invitation_token: invitation_token,
		}.render(),
	};

	result.map_err(|e| format_err!("{}", e))
}

fn generate_html(intermediate: &str) -> Result<String, Error> {
	Ok(intermediate.to_owned())
}

fn send_email(email_kind: &EmailKind, html: &str) -> Result<(), Error> {
	let config = get_config()?;

	let email = email_for_email_kind(email_kind);
	let from = config.system_email.to_owned();
	let to = vec![email.to_owned()];
	let subject = subject_for_email_kind(email_kind);

	let client = SesClient::new(Region::UsEast1);

	let body = Body {
		html: Some(Content {
			charset: Some(String::from("UTF-8")),
			data: html.to_owned(),
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
		.map_err(|e| format_err!("{}", e))
		.map(|_response| ())
}

fn email_for_email_kind(email_kind: &EmailKind) -> String {
	match email_kind {
		EmailKind::ConfirmEmail { email, .. } => email.to_owned(),
		EmailKind::Invite { email, .. } => email.to_owned(),
	}
}

fn subject_for_email_kind(email_kind: &EmailKind) -> String {
	match email_kind {
		EmailKind::ConfirmEmail { .. } => "Confirm your email".to_owned(),
		EmailKind::Invite { .. } => "You have been invited".to_owned(),
	}
}

struct Config {
	system_email: String,
}

fn get_config() -> Result<Config, Error> {
	let system_email = env::var("SYSTEM_EMAIL").map_err(|_| format_err!("SYSTEM_EMAIL not found"))?;

	Ok(Config {
		system_email: system_email,
	})
}

#[cfg(test)]
mod tests {
	use super::*;
	use chrono::prelude::*;
	use lambda::event::sns::{SnsEntity, SnsEvent, SnsEventRecord};
	use std::collections::HashMap;

	fn build_event(message: &str) -> SnsEvent {
		let message_attributes = HashMap::new();
		let timestamp = Utc::now();

		let record = SnsEventRecord {
			event_source: None,
			event_subscription_arn: None,
			event_version: None,
			sns: SnsEntity {
				signature: None,
				message_id: None,
				message: Some(message.to_owned()),
				message_attributes: message_attributes,
				signature_version: None,
				signing_cert_url: None,
				subject: None,
				timestamp: timestamp,
				topic_arn: None,
				type_: None,
				unsubscribe_url: None,
			},
		};

		SnsEvent {
			records: vec![record],
		}
	}

	#[test]
	fn it_gets_and_invite() {
		let bytes = include_bytes!("fixtures/invite.json");
		let json = String::from_utf8_lossy(bytes);

		let event = build_event(&json);

		let email_kind = get_email_kind(&event).unwrap();

		let expected = EmailKind::Invite {
			inviter: "sam@sample.com".to_owned(),
			email: "sally@sample.com".to_owned(),
			invitation_token: "abc".to_owned(),
		};

		assert_eq!(email_kind, expected);
	}

	#[test]
	fn it_builds_intermediate() {
		let email_kind = EmailKind::Invite {
			inviter: "sam@sample.com".to_owned(),
			email: "sally@sample.com".to_owned(),
			invitation_token: "abc".to_owned(),
		};

		let _result = generate_intermidiate(&email_kind).unwrap();
	}

	#[test]
	fn it_generates_html() {
		let intermediate = "<intermediate>Hello</intermediate>";
		let result = generate_html(intermediate).unwrap();

		assert_eq!(result, intermediate)
	}
}
