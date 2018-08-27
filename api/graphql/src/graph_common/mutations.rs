use failure::Error;
// use juniper::FieldResult;
use validator::{ValidationError, ValidationErrors};

#[derive(GraphQLObject, Clone)]
pub struct MutationError {
	pub key: String,
	pub messages: Vec<String>,
}

#[allow(dead_code)]
fn to_mutation_errors(errors: ValidationErrors) -> Vec<MutationError> {
	errors
		.inner()
		.iter()
		.map(|(k, v)| MutationError {
			key: k.to_string(),
			messages: to_mutation_error_messages(v.to_vec()),
		})
		.collect()
}

#[allow(dead_code)]
fn to_mutation_error_messages(errors: Vec<ValidationError>) -> Vec<String> {
	errors
		.iter()
		.map(|e| {
			e.clone()
				.message
				.unwrap_or(::std::borrow::Cow::Borrowed("Invalid"))
				.to_string()
		})
		.collect()
}

pub fn failure_to_mutation_errors(error: Error) -> Vec<MutationError> {
	let mutation_error = MutationError {
		key: "other".to_owned(),
		messages: vec![error.to_string()],
	};

	vec![mutation_error]
}
