use graph_common::mutations::MutationError;
use graph_pub::actions::sign_ins;
use graph_pub::actions::users::make_token;
use graph_pub::context::PublicContext;
use juniper::{Executor, FieldResult};
use models::sign_in::SignIn;
use graph_common::mutations::failure_to_mutation_errors;

#[derive(GraphQLObject, Clone)]
pub struct SignInResponse {
	success: bool,
	errors: Vec<MutationError>,
	token: Option<String>,
}

pub fn call(executor: &Executor<PublicContext>, sign_in: SignIn) -> FieldResult<SignInResponse> {
	let context = executor.context();

	let user_result = sign_ins::create::call(&context.conn, sign_in);

	let user = match user_result {
		Ok(user) => user,
		Err(e) => return Ok(SignInResponse {
			success: false,
			errors: failure_to_mutation_errors(e),
			token: None,
		}),
	};

	let token_result = make_token::call(user);

	let token = match token_result {
		Ok(token) => token,
		Err(e) => return Ok(SignInResponse {
			success: false,
			errors: failure_to_mutation_errors(e),
			token: None,
		}),
	};

	let response = SignInResponse {
		success: true,
		errors: vec![],
		token: Some(token),
	};

	Ok(response)
}
