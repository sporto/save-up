use failure::Error;
use validator::{ValidationErrors, ValidationErrorsKind};

#[derive(GraphQLObject, Clone)]
pub struct MutationError {
	pub key:      String,
	pub messages: Vec<String>,
}

#[allow(dead_code)]
fn to_mutation_errors(errors: ValidationErrors) -> Vec<MutationError> {
	errors
		.errors()
		.iter()
		.map(|(k, validation_error_kind)| {
			MutationError {
				key:      k.to_string(),
				messages: vec![kind_to_string(&validation_error_kind)],
			}
		})
		.collect()
}

fn kind_to_string(kind: &ValidationErrorsKind) -> String {
	format!("{:?}", kind)
}

#[allow(dead_code)]
pub fn failure_to_mutation_errors(error: Error) -> Vec<MutationError> {
	let mutation_error = MutationError {
		key:      "other".to_owned(),
		messages: vec![error.to_string()],
	};

	vec![mutation_error]
}
