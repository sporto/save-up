use juniper::{Executor, FieldError, FieldResult};

use actions::accounts::authorise;
pub use actions::transactions::deposit::{self, DepositInput};
use graph::AppContext;
use models::transaction::Transaction;
use utils::mutations::failure_to_mutation_errors;
use utils::mutations::MutationError;

#[derive(Clone)]
pub struct DepositResponse {
	success: bool,
	errors: Vec<MutationError>,
	transaction: Option<Transaction>,
}

graphql_object!(DepositResponse: AppContext |&self| {
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

pub fn call(executor: &Executor<AppContext>, input: DepositInput) -> FieldResult<DepositResponse> {
	let ctx = executor.context();
	let conn = ctx.pool.get().unwrap();
	let current_user = &ctx.user;

	// Authorise this transaction
	let can_access = authorise::can_access(&conn, input.account_id, &current_user)?;

	if can_access == false {
		return Err(FieldError::from("Unauthorised"));
	}

	let result = deposit::call(&conn, input);

	let response = match result {
		Ok(transaction) => DepositResponse {
			success: true,
			errors: vec![],
			transaction: Some(transaction),
		},
		Err(e) => DepositResponse {
			success: false,
			errors: failure_to_mutation_errors(e),
			transaction: None,
		},
	};

	Ok(response)
}
