use actions::users::confirm_email;
use graph::PublicContext;
use juniper::{Executor, FieldResult};
use utils::mutations::{failure_to_mutation_errors, MutationError};

#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct ConfirmEmailInput {
	token: String,
}

#[derive(GraphQLObject, Clone)]
pub struct ConfirmEmailResponse {
	success: bool,
	errors: Vec<MutationError>,
}

pub fn call(
	executor: &Executor<PublicContext>,
	input: ConfirmEmailInput,
) -> FieldResult<ConfirmEmailResponse> {
	let context = executor.context();

	let result = confirm_email::call(&context.conn, &input.token);

	let response = match result {
		Ok(_) => ConfirmEmailResponse {
			success: true,
			errors: vec![],
		},
		Err(e) => ConfirmEmailResponse {
			success: false,
			errors: failure_to_mutation_errors(e),
		},
	};

	Ok(response)
}
