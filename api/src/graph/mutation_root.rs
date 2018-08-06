use graph::query_root::Context;
use juniper::{FieldError, FieldResult};
use validator::{ValidationError, ValidationErrors};

// use models::errors::UpdateResult;
use models::sign_ups::SignUp;
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

graphql_object!(MutationRoot: Context | &self | {

	field sign_up(&executor, sign_up: SignUp) -> FieldResult<SignUpResponse> {
		let context = executor.context();

		let user = services
			::sign_ups
			::create
			::call(&context.conn, sign_up)?;

		let token = services
			::users
			::make_token
			::call(user)
			.map_err(|_| "Failed to make JWT Token".to_owned() )?;

		let response = SignUpResponse {
			success: true,
			errors: vec![],
			token: Some(token),
		};

		Ok(response)
	}

});
