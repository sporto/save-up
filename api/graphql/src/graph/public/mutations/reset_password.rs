use crate::{
	actions::{passwords, users::make_jwt},
	graph::PublicContext,
	utils::mutations::{failure_to_mutation_errors, MutationError},
};
use failure::Error;
use juniper::{Executor, FieldResult};

#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct ResetPasswordInput {
	token:    String,
	password: String,
}

#[derive(GraphQLObject, Clone)]
pub struct ResetPasswordResponse {
	success: bool,
	errors:  Vec<MutationError>,
	jwt:     Option<String>,
}

pub fn call(
	executor: &Executor<PublicContext>,
	input: ResetPasswordInput,
) -> FieldResult<ResetPasswordResponse> {
	let ctx = executor.context();
	let conn = &ctx.conn;

	let result = passwords::reset::call(&conn, &input.token, &input.password);

	let user = match result {
		Ok(user) => user,
		Err(e) => return Ok(other_error(e)),
	};

	let token_result = make_jwt::call(user);

	let token = match token_result {
		Ok(token) => token,
		Err(e) => return Ok(other_error(e)),
	};

	let response = ResetPasswordResponse {
		success: true,
		errors:  vec![],
		jwt:     Some(token),
	};

	Ok(response)
}

fn other_error(error: Error) -> ResetPasswordResponse {
	ResetPasswordResponse {
		success: false,
		errors:  failure_to_mutation_errors(error),
		jwt:     None,
	}
}
