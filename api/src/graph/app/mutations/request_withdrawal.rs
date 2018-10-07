use juniper::{Executor, FieldError, FieldResult};

use actions::accounts::authorise;
use actions::transactions::request_withdrawal;
pub use actions::transactions::request_withdrawal::RequestWithdrawalInput;
use graph::AppContext;
use models::transaction_request::TransactionRequest;
use utils::mutations::failure_to_mutation_errors;
use utils::mutations::MutationError;

#[derive(Clone)]
pub struct RequestWithdrawalResponse {
	success: bool,
	errors: Vec<MutationError>,
	transaction_request: Option<TransactionRequest>,
}

graphql_object!(RequestWithdrawalResponse: AppContext |&self| {
	field success() -> bool {
		self.success
	}

	field errors() -> &Vec<MutationError> {
		&self.errors
	}

	field transaction_request() -> &Option<TransactionRequest> {
		&self.transaction_request
	}
});

pub fn call(
	executor: &Executor<AppContext>,
	input: RequestWithdrawalInput,
) -> FieldResult<RequestWithdrawalResponse> {
	let context = executor.context();
	let conn = &context.conn;
	let current_user = &context.user;

	// Authorise
	let can_access = authorise::can_access(&conn, input.account_id, &current_user)?;

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
