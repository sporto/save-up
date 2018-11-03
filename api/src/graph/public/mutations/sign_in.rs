use actions::sign_ins;
use actions::users::make_jwt;
use graph::PublicContext;
use juniper::{Executor, FieldResult};
use models::sign_in::SignIn;
use utils::mutations::failure_to_mutation_errors;
use utils::mutations::MutationError;

#[derive(GraphQLObject, Clone)]
pub struct SignInResponse {
	success: bool,
	errors: Vec<MutationError>,
	jwt: Option<String>,
}

pub fn call(executor: &Executor<PublicContext>, sign_in: SignIn) -> FieldResult<SignInResponse> {
	let ctx = executor.context();
	let conn = ctx.pool.get().unwrap();

	let user_result = sign_ins::create::call(&conn, sign_in);

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
