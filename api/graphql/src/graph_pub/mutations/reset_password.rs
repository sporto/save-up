use failure::Error;
use graph_common::actions::passwords;
use graph_common::mutations::{failure_to_mutation_errors, MutationError};
use graph_pub::context::PublicContext;
use juniper::{Executor, FieldResult};

#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct ResetPasswordInput {
	username_or_email: String,
}

#[derive(GraphQLObject, Clone)]
pub struct ResetPasswordResponse {
	success: bool,
	errors: Vec<MutationError>,
	token: Option<String>,
}

pub fn call(
	executor: &Executor<PublicContext>,
	input: ResetPasswordInput,
) -> FieldResult<ResetPasswordResponse> {
	let context = executor.context();

	let result = passwords::reset::call(&context.conn, &input.username_or_email);

	let response = match result {
		Ok(token) => ResetPasswordResponse {
			success: true,
			errors: vec![],
			token: Some(token),
		},
		Err(e) => other_error(e),
	};

	Ok(response)
}

fn other_error(error: Error) -> ResetPasswordResponse {
	ResetPasswordResponse {
		success: false,
		errors: failure_to_mutation_errors(error),
		token: None,
	}
}
