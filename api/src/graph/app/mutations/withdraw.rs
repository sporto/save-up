use actions::accounts::authorise;
pub use actions::transactions::withdraw::{self, WithdrawalInput};
use graph::AppContext;
use juniper::{Executor, FieldError, FieldResult};
use models::transaction::Transaction;
use utils::mutations::failure_to_mutation_errors;
use utils::mutations::MutationError;

#[derive(Clone)]
pub struct WithdrawalResponse {
	success: bool,
	errors: Vec<MutationError>,
	transaction: Option<Transaction>,
}

graphql_object!(WithdrawalResponse: AppContext |&self| {
	field success() -> bool {
		self.success
	}

	field errors() -> &Vec<MutationError> {
		&self.errors
	}

	field transaction() -> &Option<Transaction> {
		&self.transaction
	}
});

pub fn call(
	executor: &Executor<AppContext>,
	input: WithdrawalInput,
) -> FieldResult<WithdrawalResponse> {
	let ctx = executor.context();
	let conn = &ctx.conn;
	let current_user = &ctx.user;

	// Authorise this transaction
	let can_access = authorise::can_access(&conn, input.account_id, &current_user)?;

	if can_access == false {
		return Err(FieldError::from("Unauthorised"));
	}

	let result = withdraw::call(&conn, input);

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
