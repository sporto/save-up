use actions::emails::send;
use failure::Error;
use models::email_kinds::EmailKind;
use models::user::User;
use utils::links;

pub fn call(user: &User) -> Result<(), Error> {
	let confirmation_token = user
		.clone()
		.email_confirmation_token
		.ok_or(format_err!("Missing email_confirmation_token"))?;

	let url = links::email_confirmation_url(&confirmation_token)?;

	let email = match user.email {
		Some(ref email) => email,
		None => return Ok(()),
	};

	let email_kind = EmailKind::ConfirmEmail {
		email: email.to_string(),
		confirmation_url: url.to_string(),
	};

	send::call(&email_kind)
}
