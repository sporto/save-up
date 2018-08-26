use graph_app::context::AppContext;
use graph_common::mutations::MutationError;
use juniper::{Executor, FieldResult};
use services;

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
		Err(_e) => {
			let mutation_error = MutationError {
				key: "other".to_owned(),
				messages: vec!["Failed to invite".to_owned()],
			};

			return Ok(InvitationResponse {
				success: false,
				errors: vec![mutation_error],
			});
		}
	};

	Ok(InvitationResponse {
		success: true,
		errors: vec![],
	})
}
