use actions;
use actions::passwords;
use graphql::AppContext;
use juniper::{Executor, FieldError, FieldResult};
use models::role::Role;
use models::user::{User, UserAttrs};
use utils::mutations::failure_to_mutation_errors;
use utils::mutations::MutationError;

#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct CreateUserInput {
	pub email: Option<String>,
	pub username: String,
	pub name: String,
	pub password: String,
}

#[derive(Clone)]
pub struct CreateUserResponse {
	success: bool,
	errors: Vec<MutationError>,
	user: Option<User>,
}

graphql_object!(CreateUserResponse: AppContext |&self| {
	field success() -> bool {
		self.success
	}

	field errors() -> &Vec<MutationError> {
		&self.errors
	}

	field user() -> &Option<User> {
		&self.user
	}
});

pub fn call(
	executor: &Executor<AppContext>,
	input: CreateUserInput,
) -> FieldResult<CreateUserResponse> {
	let context = executor.context();
	let conn = &context.conn;
	let current_user = &context.user;

	// Authorise
	let can = actions::users::authorise::can_create(&conn, &current_user)?;

	if can == false {
		return Err(FieldError::from("Unauthorised"));
	}

	let password_hash =
		passwords::encrypt::call(&input.password).map_err(|e| format_err!("{}", e))?;

	let user_attrs = UserAttrs {
		client_id: current_user.client_id,
		email: None,
		password_hash: password_hash,
		name: input.name,
		role: Role::Investor,
		email_confirmation_token: None,
		email_confirmed_at: None,
		username: input.username,
		archived_at: None,
		password_reset_token: None,
	};

	let user_result = actions::users::create::call(&conn, user_attrs);

	let response = match user_result {
		Ok(user) => CreateUserResponse {
			success: true,
			errors: vec![],
			user: Some(user),
		},
		Err(e) => CreateUserResponse {
			success: false,
			errors: failure_to_mutation_errors(e),
			user: None,
		},
	};

	Ok(response)
}
