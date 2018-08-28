use graph_app::context::AppContext;
use graph_common::mutations::MutationError;
use juniper::{Executor, FieldResult};
use services;
use graph_common::mutations::failure_to_mutation_errors;

#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct InvitationInput {
	pub email: String,
}

#[derive(GraphQLObject, Clone)]
pub struct InvitationResponse {
	success: bool,
	errors: Vec<MutationError>,
}

pub fn call(
	executor: &Executor<AppContext>,
	input: InvitationInput,
) -> FieldResult<InvitationResponse> {
	let context = executor.context();

	let invitation_result =
		services::invitations::create::call(&context.conn, &context.user, &input.email);

	match invitation_result {
		Ok(invitation) => invitation,
		Err(e) => {
			return Ok(InvitationResponse {
				success: false,
				errors: failure_to_mutation_errors(e),
			});
		}
	};

	Ok(InvitationResponse {
		success: true,
		errors: vec![],
	})
}
