use crate::{
	actions::users::confirm_email,
	graph::PublicContext,
	utils::mutations::{failure_to_mutation_errors, MutationError},
};
use juniper::{Executor, FieldResult};

#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct ConfirmEmailInput {
	token: String,
}

#[derive(GraphQLObject, Clone)]
pub struct ConfirmEmailResponse {
	success: bool,
	errors:  Vec<MutationError>,
}

pub fn call(
	executor: &Executor<PublicContext>,
	input: ConfirmEmailInput,
) -> FieldResult<ConfirmEmailResponse> {
	let ctx = executor.context();
	let conn = &ctx.conn;

	let result = confirm_email::call(&conn, &input.token);

	let response = match result {
		Ok(_) => {
			ConfirmEmailResponse {
				success: true,
				errors:  vec![],
			}
		},
		Err(e) => {
			ConfirmEmailResponse {
				success: false,
				errors:  failure_to_mutation_errors(e),
			}
		},
	};

	Ok(response)
}
