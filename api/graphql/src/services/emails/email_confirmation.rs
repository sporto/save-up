use super::send;
use failure::Error;
use models::user::User;
// use rusoto_core::Region;
use rusoto_sns::{PublishInput, Sns, SnsClient};
use shared::email_kinds::EmailKind;

pub fn call(user: &User) -> Result<(), Error> {
	let confirmation_token = user
		.clone()
		.email_confirmation_token
		.ok_or(format_err!("Missing email_confirmation_token"))?;

	let email_kind = EmailKind::ConfirmEmail {
		email: user.clone().email,
		confirmation_token: confirmation_token.to_string(),
	};

	send::call(&email_kind)
}
