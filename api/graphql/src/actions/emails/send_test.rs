use failure::Error;

use crate::{
	actions::emails::send,
};
use shared::emails::{Email, EmailKind};
use crate::utils::config;

pub fn call() -> Result<(), Error> {
	let config = config::get()?;
	let email_kind = EmailKind::Test {};

	let email = Email {
		to: config.observer_email,
		kind: email_kind,
	};

	send::call(&email)
}
