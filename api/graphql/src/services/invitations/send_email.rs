use rusoto_core::Region;
use rusoto_ses::{SesClient,Ses,Destination,Message,SendEmailRequest, Body, Content};
use std::default::Default;
use std::time::Duration;
use models::users::User;
use models::invitations::Invitation;
use failure::Error;

pub fn call(_user: &User, invitation: &Invitation) -> Result<(), Error> {

	let from = "hello@kidinv.co".to_owned();
	let to = vec!(invitation.email.clone());
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
