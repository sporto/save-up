use models::sign_ups::SignUp;
use juniper::{Executor, FieldResult};
use graph::mutation_root::MutationError;
use services;
use graph::context::Context;

#[derive(GraphQLObject, Clone)]
pub struct SignUpResponse {
	success: bool,
	errors: Vec<MutationError>,
	token: Option<String>,
}

pub fn call(executor: &Executor<Context>, sign_up: SignUp) -> FieldResult<SignUpResponse> {

	fn other_error(message: String) -> SignUpResponse {
		let mutation_error = MutationError { 
			key: "other".to_owned(),
			messages: vec![message]
		};

		SignUpResponse {
			success: false,
			errors: vec![ mutation_error],
			token: None,
		}
	}

	let context = executor.context();

	let user_result = services
		::sign_ups
		::create
		::call(&context.conn, sign_up);
	
	let user = match user_result {
		Ok(user) =>
			user,
		Err(e) =>
			return Ok(other_error(e))
	};

	let token_result = services
		::users
		::make_token
		::call(user)
		.map_err(|_| "Failed to make JWT Token".to_owned() );

	let token = match token_result {
		Ok(token) =>
			token,
		Err(e) =>
			return Ok(other_error(e))
	};

	let response = SignUpResponse {
		success: true,
		errors: vec![],
		token: Some(token),
	};

	Ok(response)
}
