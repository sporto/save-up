use juniper::{Executor, FieldError, FieldResult};

use graph_app::actions::accounts::authorise;
use graph_app::actions::transactions::request_withdrawal;
pub use graph_app::actions::transactions::request_withdrawal::RequestWithdrawalInput;
use graph_app::context::AppContext;
use graph_common::mutations::failure_to_mutation_errors;
use graph_common::mutations::MutationError;
use models::transaction_request::TransactionRequest;

#[derive(GraphQLObject, Clone)]
pub struct RequestWithdrawalResponse {
	success: bool,
	errors: Vec<MutationError>,
	transaction_request: Option<TransactionRequest>,
}

pub fn call(
	executor: &Executor<AppContext>,
	input: RequestWithdrawalInput,
) -> FieldResult<RequestWithdrawalResponse> {
	let context = executor.context();
	let conn = &context.conn;
	let current_user = &context.user;

	// Authorise
	let can_access = authorise::call(&conn, input.account_id, &current_user)?;

	if can_access == false {
		return Err(FieldError::from("Unauthorised"));
	}

	let result = request_withdrawal::call(&context.conn, input);

	let response = match result {
		Ok(transaction_request) => RequestWithdrawalResponse {
			success: true,
			errors: vec![],
			transaction_request: Some(transaction_request),
		},
		Err(e) => RequestWithdrawalResponse {
			success: false,
			errors: failure_to_mutation_errors(e),
			transaction_request: None,
		},
	};

	Ok(response)
}
