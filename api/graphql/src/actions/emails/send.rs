use failure::Error;
use rusoto_core::Region;
use rusoto_sns::{Sns,PublishInput, SnsClient};
use shared::email_kinds::EmailKind;

pub fn call(email_kind: &EmailKind) -> Result<(), Error> {
	let client = SnsClient::new(Region::ApSoutheast1);

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

	client
		.publish(input)
		.sync()
		.map_err(|err| format_err!("{}", err))
		.map(|_| ())
}
