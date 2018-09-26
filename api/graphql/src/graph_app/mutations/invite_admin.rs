use graph_app::actions::invitations;
use graph_app::actions::invitations::authorise;
use graph_app::context::AppContext;
use graph_common::mutations::failure_to_mutation_errors;
use graph_common::mutations::MutationError;
use juniper::{Executor, FieldError, FieldResult};
use models::role::Role;

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
	let conn = &context.conn;
	let current_user = &context.user;

	// Authorise
	let can = authorise::call(&conn, &current_user)?;

	if can == false {
		return Err(FieldError::from("Unauthorised"));
	}

	let invitation_result =
		invitations::create::call(&conn, &current_user, &input.email, Role::Admin);

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
