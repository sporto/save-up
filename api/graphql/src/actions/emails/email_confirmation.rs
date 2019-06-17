use crate::{
	actions::emails::send,
	models::{user::User},
	utils::links,
};
use shared::emails::{Email, EmailKind};

use failure::Error;

pub fn call(user: &User) -> Result<(), Error> {
	let confirmation_token = user
		.clone()
		.email_confirmation_token
		.ok_or(format_err!("Missing email_confirmation_token"))?;

	let url = links::email_confirmation_url(&confirmation_token)?;

	let email_address = match user.email {
		Some(ref email) => email,
		None => return Ok(()),
	};

	let email_kind = EmailKind::ConfirmEmail {
		confirmation_url: url.to_string(),
	};

	let email = Email {
		to: email_address.to_string(),
		kind: email_kind,
	};

	send::call(&email)
}
