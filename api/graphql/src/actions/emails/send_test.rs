use failure::Error;

use crate::{
	actions::emails::send,
};
use shared::email_kinds::EmailKind;


pub fn call() -> Result<(), Error> {
	let email_kind = EmailKind::Test {
		email: "sebasporto@gmail.com".to_string(),
	};

	send::call(&email_kind)
}
