use juniper::{Executor, FieldError, FieldResult};

use graph_app::context::AppContext;
use graph_common::mutations::failure_to_mutation_errors;
use graph_common::mutations::MutationError;
use models::transaction::Transaction;
use authorisers;
pub use graph_app::actions::transactions::deposit::{self, DepositInput};

#[derive(GraphQLObject, Clone)]
pub struct DepositResponse {
	success: bool,
	errors: Vec<MutationError>,
	transaction: Option<Transaction>,
}

pub fn call(executor: &Executor<AppContext>, input: DepositInput) -> FieldResult<DepositResponse> {
	let context = executor.context();

	let conn = &context.conn;

	// Authorise this transaction
	let can_access = authorisers::accounts::access(&conn, input.account_id, &context.user)?;

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
