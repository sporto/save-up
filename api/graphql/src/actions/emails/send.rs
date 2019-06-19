use failure::Error;
use rusoto_core::Region;
use rusoto_sns::{Sns,PublishInput, SnsClient};
use shared::emails::Email;
use crate::{
	utils::config,
};

pub fn call(email: &Email) -> Result<(), Error> {
	let config = config::get()?;
	let client = SnsClient::new(Region::UsEast1);

	let message = json!(email);

	let input = PublishInput {
		message: message.to_string(),
		message_attributes: None,
		message_structure: None,
		phone_number: None,
		subject: None,
		target_arn: None,
		topic_arn: Some(config.aws_sns_email_topic_arn),
	};

	if (config.env == config::AppEnv::Test) {
		return Ok(());
	};

	client
		.publish(input)
		.sync()
		.map_err(|err| format_err!("{}", err))
		.map(|_| ())
}
