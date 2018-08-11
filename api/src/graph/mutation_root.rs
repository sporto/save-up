use juniper::{FieldResult};
use validator::{ValidationError, ValidationErrors};

use models::sign_ups::SignUp;
use models::sign_ins::SignIn;
use graph::mutations;
use graph::context::Context;

pub struct MutationRoot;

#[derive(GraphQLObject, Clone)]
pub struct MutationError {
	pub  key: String,
	pub  messages: Vec<String>,
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

graphql_object!(MutationRoot: Context | &self | {

	field signUp(&executor, sign_up: SignUp) -> FieldResult<mutations::sign_up::SignUpResponse> {
		mutations::sign_up::call(executor, sign_up)
	}

	field signIn(&executor, sign_in: SignIn) -> FieldResult<mutations::sign_in::SignInResponse> {
		mutations::sign_in::call(executor, sign_in)
	}

	field invite(&executor, attrs: mutations::invite::InvitationInput) -> FieldResult<mutations::invite::InvitationResponse> {
		mutations::invite::call(executor, attrs)
	}

});
