pub use crate::actions::invitations::redeem::RedeemInvitationInput;
use crate::{
	actions::{invitations::redeem, users::make_jwt},
	graph::PublicContext,
	models::user::User,
	utils::mutations::{failure_to_mutation_errors, MutationError},
};
use failure::Error;
use juniper::{Executor, FieldResult};

#[derive(GraphQLObject, Clone)]
pub struct RedeemInvitationResponse {
	success: bool,
	errors:  Vec<MutationError>,
	jwt:     Option<String>,
}

pub fn call(
	executor: &Executor<PublicContext>,
	input: RedeemInvitationInput,
) -> FieldResult<RedeemInvitationResponse> {
	let ctx = executor.context();
	let conn = &ctx.conn;

	let result = redeem::call(&conn, &input);

	let response = match result {
		Ok(user) => with_user(user),
		Err(e) => other_error(e),
	};

	Ok(response)
}

fn other_error(error: Error) -> RedeemInvitationResponse {
	RedeemInvitationResponse {
		success: false,
		errors:  failure_to_mutation_errors(error),
		jwt:     None,
	}
}

fn with_user(user: User) -> RedeemInvitationResponse {
	let jwt_result = make_jwt::call(user);

	let jwt = match jwt_result {
		Ok(jwt) => jwt,
		Err(e) => return other_error(e),
	};

	RedeemInvitationResponse {
		success: true,
		errors:  vec![],
		jwt:     Some(jwt),
	}
}
