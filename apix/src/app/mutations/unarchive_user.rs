use actions;
use app::context::AppContext;
use juniper::{Executor, FieldError, FieldResult};
use utils::mutations::MutationError;

#[derive(Clone)]
pub struct UnarchiveUserResponse {
	success: bool,
	errors: Vec<MutationError>,
}

graphql_object!(UnarchiveUserResponse: AppContext |&self| {
	field success() -> bool {
		self.success
	}

	field errors() -> &Vec<MutationError> {
		&self.errors
	}
});

pub fn call(executor: &Executor<AppContext>, user_id: i32) -> FieldResult<UnarchiveUserResponse> {
	let context = executor.context();
	let conn = &context.conn;
	let current_user = &context.user;

	// Authorise
	let can = actions::users::authorise::can_archive(&conn, &current_user, user_id)?;

	if can == false {
		return Err(FieldError::from("Unauthorised"));
	}

	actions::users::unarchive::call(&conn, user_id)?;

	let response = UnarchiveUserResponse {
		success: true,
		errors: vec![],
	};

	Ok(response)
}
