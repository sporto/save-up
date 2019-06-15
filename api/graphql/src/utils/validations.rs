use validator::{ValidationErrors,ValidationError};
use std::collections::hash_map::Values;

pub fn to_human_error(e: ValidationErrors) -> String {
	let field_errors = e.field_errors();

	let maybe_first_error: Option<&ValidationError> = field_errors
		.values()
		.next()
		.and_then(|errors| errors.first() );

	let first_message: Option<String> = maybe_first_error
		.and_then(|error| error.clone().message)
		.map(|message| message.into_owned() );

	first_message
		.unwrap_or("No error found".to_string())
}
