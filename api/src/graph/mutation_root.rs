use graph::query_root::Context;
use juniper::{FieldResult};
use validator::{ValidationError, ValidationErrors};

// use models::errors::UpdateResult;
use models::sign_ups::SignUp;
use models::sign_ins::SignIn;
use services;

pub struct MutationRoot;

#[derive(GraphQLObject, Clone)]
struct MutationError {
	key: String,
	messages: Vec<String>,
}

#[allow(dead_code)]
fn to_mutation_errors(errors: ValidationErrors) -> Vec<MutationError> {
	errors
		.inner()
		.iter()
		.map(|(k, v)| MutationError {
			key: k.to_string(),
			messages: to_mutation_error_messages(v.to_vec()),
		})
		.collect()
}

#[allow(dead_code)]
fn to_mutation_error_messages(errors: Vec<ValidationError>) -> Vec<String> {
	errors
		.iter()
		.map(|e| {
			e.clone()
				.message
				.unwrap_or(::std::borrow::Cow::Borrowed("Invalid"))
				.to_string()
		})
		.collect()
}

#[derive(GraphQLObject, Clone)]
struct SignUpResponse {
	success: bool,
	errors: Vec<MutationError>,
	token: Option<String>,
}

#[derive(GraphQLObject, Clone)]
struct SignInResponse {
	success: bool,
	errors: Vec<MutationError>,
	token: Option<String>,
}

graphql_object!(MutationRoot: Context | &self | {

	field signUp(&executor, sign_up: SignUp) -> FieldResult<SignUpResponse> {

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

	field signIn(&executor, sign_in: SignIn) -> FieldResult<SignInResponse> {

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

});
