use crate::{
	actions::{sign_ups, users::make_jwt},
	graph::PublicContext,
	models::sign_up::SignUp,
	utils::mutations::{failure_to_mutation_errors, MutationError},
};
use failure::Error;
use juniper::{Executor, FieldResult};

#[derive(GraphQLObject, Clone)]
pub struct SignUpResponse {
	success: bool,
	errors:  Vec<MutationError>,
	jwt:     Option<String>,
}

pub fn call(executor: &Executor<PublicContext>, sign_up: SignUp) -> FieldResult<SignUpResponse> {
	fn other_error(error: Error) -> SignUpResponse {
		SignUpResponse {
			success: false,
			errors:  failure_to_mutation_errors(error),
			jwt:     None,
		}
	}

	let ctx = executor.context();
	let conn = &ctx.conn;

	let user_result = sign_ups::create::call(&conn, sign_up);

	let user = match user_result {
		Ok(user) => user,
		Err(e) => return Ok(other_error(e)),
	};

	let jwt_result = make_jwt::call(user);

	let jwt = match jwt_result {
		Ok(jwt) => jwt,
		Err(e) => return Ok(other_error(e)),
	};

	let response = SignUpResponse {
		success: true,
		errors:  vec![],
		jwt:     Some(jwt),
	};

	Ok(response)
}
