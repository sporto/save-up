use actions::passwords;
use failure::Error;
use graph::PublicContext;
use juniper::{Executor, FieldResult};
use utils::mutations::{failure_to_mutation_errors, MutationError};

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
	let ctx = executor.context();
	let conn = ctx.pool.get().unwrap();

	let result = passwords::request_reset::call(&conn, &input.username_or_email);

	let response = match result {
		Ok(_token) => RequestPasswordResetResponse {
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
