use failure::Error;
use libreauth::pass::ErrorCode;
use libreauth::pass::HashBuilder;

fn error_to_string(error: ErrorCode) -> String {
	match error {
		ErrorCode::Success => "Success".to_owned(),
		ErrorCode::PasswordTooShort => "The password is too short".to_owned(),
		ErrorCode::PasswordTooLong => "The password is too long".to_owned(),
		ErrorCode::InvalidPasswordFormat => "The password has invalid format".to_owned(),
		ErrorCode::IncompatibleOption => "IncompatibleOption".to_owned(),
		ErrorCode::NotEnoughSpace => "NotEnoughSpace".to_owned(),
		ErrorCode::NullPtr => "NullPtr".to_owned(),
	}
}

pub fn call(password: &str) -> Result<String, Error> {
	let hasher = HashBuilder::new()
		.finalize()
		.map_err(|e| format_err!("{}", error_to_string(e)))?;

	hasher
		.hash(&password.to_owned())
		.map_err(|e| format_err!("{}", error_to_string(e)))
}
