use graph_common::mutations::{failure_to_mutation_errors, MutationError};
use graph_pub::context::PublicContext;
use juniper::{Executor, FieldResult};
use models::user::User;
use graph_pub::actions::invitations::redeem;
pub use graph_pub::actions::invitations::redeem::RedeemInvitationInput;

#[derive(GraphQLObject, Clone)]
pub struct RedeemInvitationResponse {
	success: bool,
	errors: Vec<MutationError>,
	user: Option<User>,
}

pub fn call(
	executor: &Executor<PublicContext>,
	input: RedeemInvitationInput,
) -> FieldResult<RedeemInvitationResponse> {
	let context = executor.context();

	let result = redeem::call(&context.conn, &input);

	let response = match result {
		Ok(user) => RedeemInvitationResponse {
			success: true,
			errors: vec![],
			user: Some(user),
		},
		Err(e) => RedeemInvitationResponse {
			success: false,
			errors: failure_to_mutation_errors(e),
			user: None,
		},
	};

	Ok(response)
}
