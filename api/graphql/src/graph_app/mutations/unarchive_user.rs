use graph_app::actions;
use graph_app::context::AppContext;
use graph_common::mutations::MutationError;
use juniper::{Executor, FieldError, FieldResult};

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
