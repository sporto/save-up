use juniper::{Executor, FieldError, FieldResult};

pub use crate::actions::transactions::request_withdrawal::RequestWithdrawalInput;
use crate::{
	actions::{accounts::authorise, transactions::request_withdrawal},
	graph::AppContext,
	models::transaction_request::TransactionRequest,
	utils::mutations::{failure_to_mutation_errors, MutationError},
};

#[derive(Clone)]
pub struct RequestWithdrawalResponse {
	success:             bool,
	errors:              Vec<MutationError>,
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
	let ctx = executor.context();
	let conn = &ctx.conn;
	let current_user = &ctx.user;

	// Authorise
	let can_access = authorise::can_access(&conn, input.account_id, &current_user)?;

	if can_access == false {
		return Err(FieldError::from("Unauthorised"));
	}

	let result = request_withdrawal::call(&conn, input);

	let response = match result {
		Ok(transaction_request) => {
			RequestWithdrawalResponse {
				success:             true,
				errors:              vec![],
				transaction_request: Some(transaction_request),
			}
		},
		Err(e) => {
			RequestWithdrawalResponse {
				success:             false,
				errors:              failure_to_mutation_errors(e),
				transaction_request: None,
			}
		},
	};

	Ok(response)
}
