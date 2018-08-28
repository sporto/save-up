use graph_app::context::AppContext;
use graph_common::mutations::failure_to_mutation_errors;
use graph_common::mutations::MutationError;
use juniper::{Executor, FieldResult};
use models::transactions::Transaction;
pub use services::transactions::deposit::{self, DepositInput};

#[derive(GraphQLObject, Clone)]
pub struct DepositResponse {
	success: bool,
	errors: Vec<MutationError>,
	transaction: Option<Transaction>,
}

pub fn call(executor: &Executor<AppContext>, input: DepositInput) -> FieldResult<DepositResponse> {
	let context = executor.context();

	let result = deposit::call(&context.conn, input);

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
