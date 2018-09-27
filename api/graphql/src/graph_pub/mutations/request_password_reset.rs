use failure::Error;
use graph_common::actions::passwords;
use graph_common::mutations::{failure_to_mutation_errors, MutationError};
use graph_pub::context::PublicContext;
use juniper::{Executor, FieldResult};

#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct RequestPasswordResetInput {
	username_or_email: String,
}

#[derive(GraphQLObject, Clone)]
pub struct RequestPasswordResetResponse {
	success: bool,
	errors: Vec<MutationError>,
}

pub fn call(
	executor: &Executor<PublicContext>,
	input: RequestPasswordResetInput,
) -> FieldResult<RequestPasswordResetResponse> {
	let context = executor.context();

	let result = passwords::request_reset::call(&context.conn, &input.username_or_email);

	let response = match result {
		Ok(token) => RequestPasswordResetResponse {
			success: true,
			errors: vec![],
		},
		Err(e) => other_error(e),
	};

	Ok(response)
}

fn other_error(error: Error) -> RequestPasswordResetResponse {
	RequestPasswordResetResponse {
		success: false,
		errors: failure_to_mutation_errors(error),
	}
}
