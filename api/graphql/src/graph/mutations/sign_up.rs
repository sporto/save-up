use failure::Error;
use graph::context::PublicContext;
use graph::mutation_root::{MutationError,failure_to_mutation_errors};
use juniper::{Executor, FieldResult};
use models::sign_up::SignUp;
use services;

#[derive(GraphQLObject, Clone)]
pub struct SignUpResponse {
	success: bool,
	errors: Vec<MutationError>,
	token: Option<String>,
}

pub fn call(executor: &Executor<PublicContext>, sign_up: SignUp) -> FieldResult<SignUpResponse> {
	fn other_error(error: Error) -> SignUpResponse {
		SignUpResponse {
			success: false,
			errors: failure_to_mutation_errors(error),
			token: None,
		}
	}

	let context = executor.context();

	let user_result = services::sign_ups::create::call(&context.conn, sign_up);

	let user = match user_result {
		Ok(user) => user,
		Err(e) => return Ok(other_error(e)),
	};

	let token_result = services::users::make_token::call(user);

	let token = match token_result {
		Ok(token) => token,
		Err(e) => return Ok(other_error(e)),
	};

	let response = SignUpResponse {
		success: true,
		errors: vec![],
		token: Some(token),
	};

	Ok(response)
}
