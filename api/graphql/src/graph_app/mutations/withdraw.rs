pub use graph_app::actions::transactions::withdraw::{self, WithdrawalInput};
use graph_app::context::AppContext;
use graph_common::mutations::failure_to_mutation_errors;
use graph_common::mutations::MutationError;
use juniper::{Executor, FieldResult};
use models::transaction::Transaction;

#[derive(GraphQLObject, Clone)]
pub struct WithdrawalResponse {
	success: bool,
	errors: Vec<MutationError>,
	transaction: Option<Transaction>,
}

pub fn call(
	executor: &Executor<AppContext>,
	input: WithdrawalInput,
) -> FieldResult<WithdrawalResponse> {
	let context = executor.context();

	let conn = &context.conn;

	// Authorise this transaction
	let can_access = authorise::call(&conn, input.account_id, &context.user)?;

	if can_access == false {
		return Err(FieldError::from("Unauthorised"));
	}

	let result = withdraw::call(&context.conn, input);

	let response = match result {
		Ok(transaction) => WithdrawalResponse {
			success: true,
			errors: vec![],
			transaction: Some(transaction),
		},
		Err(e) => WithdrawalResponse {
			success: false,
			errors: failure_to_mutation_errors(e),
			transaction: None,
		},
	};

	Ok(response)
}
