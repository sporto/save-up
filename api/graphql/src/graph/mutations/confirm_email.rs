use graph::context::PublicContext;
use graph::mutation_root::{MutationError,failure_to_mutation_errors};
use juniper::{Executor, FieldResult};
use services;

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

	let result = services::users::confirm_email::call(&context.conn, &input.token);

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
