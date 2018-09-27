use graph_common::mutations::failure_to_mutation_errors;
use graph_common::mutations::MutationError;
use graph_pub::actions::sign_ins;
use graph_pub::actions::users::make_jwt;
use graph_pub::context::PublicContext;
use juniper::{Executor, FieldResult};
use models::sign_in::SignIn;

#[derive(GraphQLObject, Clone)]
pub struct SignInResponse {
	success: bool,
	errors: Vec<MutationError>,
	jwt: Option<String>,
}

pub fn call(executor: &Executor<PublicContext>, sign_in: SignIn) -> FieldResult<SignInResponse> {
	let context = executor.context();

	let user_result = sign_ins::create::call(&context.conn, sign_in);

	let user = match user_result {
		Ok(user) => user,
		Err(e) => {
			return Ok(SignInResponse {
				success: false,
				errors: failure_to_mutation_errors(e),
				jwt: None,
			})
		}
	};

	let jwt_result = make_jwt::call(user);

	let jwt = match jwt_result {
		Ok(jwt) => jwt,
		Err(e) => {
			return Ok(SignInResponse {
				success: false,
				errors: failure_to_mutation_errors(e),
				jwt: None,
			})
		}
	};

	let response = SignInResponse {
		success: true,
		errors: vec![],
		jwt: Some(jwt),
	};

	Ok(response)
}
