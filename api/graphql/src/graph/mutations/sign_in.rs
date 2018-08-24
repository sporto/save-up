use models::sign_in::SignIn;
use juniper::{Executor, FieldResult};
use graph::mutation_root::MutationError;
use services;
use graph::context::PublicContext;

#[derive(GraphQLObject, Clone)]
pub struct SignInResponse {
	success: bool,
	errors: Vec<MutationError>,
	token: Option<String>,
}

pub fn call(executor: &Executor<PublicContext>, sign_in: SignIn) -> FieldResult<SignInResponse> {
	fn other_error(message: String) -> SignInResponse {
		let mutation_error = MutationError {
			key: "other".to_owned(),
			messages: vec![message]
		};

		SignInResponse {
			success: false,
			errors: vec![ mutation_error],
			token: None,
		}
	}

	let context = executor.context();

	let user_result = services
		::sign_ins
		::create
		::call(&context.conn, sign_in);

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

	let response = SignInResponse {
		success: true,
		errors: vec![],
		token: Some(token),
	};

	Ok(response)
}
