use failure::Error;
use graph_common::mutations::{failure_to_mutation_errors, MutationError};
use graph_pub::actions::sign_ups;
use graph_pub::actions::users::make_jwt;
use graph_pub::context::PublicContext;
use juniper::{Executor, FieldResult};
use models::sign_up::SignUp;

#[derive(GraphQLObject, Clone)]
pub struct SignUpResponse {
	success: bool,
	errors: Vec<MutationError>,
	jwt: Option<String>,
}

pub fn call(executor: &Executor<PublicContext>, sign_up: SignUp) -> FieldResult<SignUpResponse> {
	fn other_error(error: Error) -> SignUpResponse {
		SignUpResponse {
			success: false,
			errors: failure_to_mutation_errors(error),
			jwt: None,
		}
	}

	let context = executor.context();

	let user_result = sign_ups::create::call(&context.conn, sign_up);

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
		errors: vec![],
		jwt: Some(jwt),
	};

	Ok(response)
}
