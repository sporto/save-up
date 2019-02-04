use crate::{
	actions::invitations::{self, authorise},
	graph::AppContext,
	models::role::Role,
	utils::mutations::{failure_to_mutation_errors, MutationError},
};
use juniper::{Executor, FieldError, FieldResult};

#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct InvitationInput {
	pub email: String,
}

#[derive(GraphQLObject, Clone)]
pub struct InvitationResponse {
	success: bool,
	errors:  Vec<MutationError>,
}

pub fn call(
	executor: &Executor<AppContext>,
	input: InvitationInput,
) -> FieldResult<InvitationResponse> {
	let ctx = executor.context();
	let conn = &ctx.conn;
	let current_user = &ctx.user;

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
				errors:  failure_to_mutation_errors(e),
			});
		},
	};

	Ok(InvitationResponse {
		success: true,
		errors:  vec![],
	})
}
