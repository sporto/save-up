use failure::Error;
use models::user::User;
use rusoto_core::Region;
use rusoto_sns::{PublishInput, Sns, SnsClient};
use shared::email_kinds::EmailKind;

pub fn call(user: &User) -> Result<(), Error> {
	let client = SnsClient::new(Region::ApSoutheast1);

	let confirmation_token = user
		.clone()
		.email_confirmation_token
		.ok_or(format_err!("Missing email_confirmation_token"))?;

	let email_kind = EmailKind::ConfirmEmail {
		email: user.clone().email,
		confirmation_token: confirmation_token.to_string(),
	};

	let message = json!(email_kind);

	let input = PublishInput {
		message: message.to_string(),
		message_attributes: None,
		message_structure: None,
		phone_number: None,
		subject: None,
		target_arn: None,
		topic_arn: Some("emails".into()),
	};

	client.publish(input);

	// client.
	// client::
	Ok(())
}
