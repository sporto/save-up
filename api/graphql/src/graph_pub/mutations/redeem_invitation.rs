use failure::Error;
use graph_common::mutations::{failure_to_mutation_errors, MutationError};
use graph_pub::context::PublicContext;
use juniper::{Executor, FieldResult};
use models::user::User;
use graph_pub::actions::invitations::redeem;
use graph_pub::actions::users::make_token;
pub use graph_pub::actions::invitations::redeem::RedeemInvitationInput;

#[derive(GraphQLObject, Clone)]
pub struct RedeemInvitationResponse {
	success: bool,
	errors: Vec<MutationError>,
	token: Option<String>,
}

pub fn call(
	executor: &Executor<PublicContext>,
	input: RedeemInvitationInput,
) -> FieldResult<RedeemInvitationResponse> {

	let context = executor.context();

	let result = redeem::call(&context.conn, &input);

	let response = match result {
		Ok(user) => with_user(user),
		Err(e) => other_error(e),
	};

	Ok(response)
}

fn other_error(error: Error) -> RedeemInvitationResponse {
	RedeemInvitationResponse {
		success: false,
		errors: failure_to_mutation_errors(error),
		token: None,
	}
}

fn with_user(user: User) -> RedeemInvitationResponse {
	let token_result = make_token::call(user);

	let token = match token_result {
		Ok(token) => token,
		Err(e) => return other_error(e),
	};

	RedeemInvitationResponse {
		success: true,
		errors: vec![],
		token: Some(token),
	}
}
