use juniper::{Executor, FieldError, FieldResult};

pub use crate::actions::transactions::resolve_transaction_request::ResolveTransactionRequestInput;
use crate::{
	actions::{accounts::authorise, transactions::resolve_transaction_request},
	graph::AppContext,
	models::transaction_request::TransactionRequest,
	utils::mutations::{failure_to_mutation_errors, MutationError},
};

#[derive(Clone)]
pub struct ResolveTransactionRequestResponse {
	success:             bool,
	errors:              Vec<MutationError>,
	transaction_request: Option<TransactionRequest>,
}

graphql_object!(ResolveTransactionRequestResponse: AppContext |&self| {
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
	input: ResolveTransactionRequestInput,
) -> FieldResult<ResolveTransactionRequestResponse> {
	let ctx = executor.context();
	let conn = &ctx.conn;

	let current_user = &ctx.user;

	// Authorise
	let transaction_request = TransactionRequest::find(&conn, input.transaction_request_id)?;

	let can = authorise::can_admin(&conn, transaction_request.account_id, &current_user)?;

	if can == false {
		return Err(FieldError::from("Unauthorised"));
	}

	let result = resolve_transaction_request::call(&conn, input);

	let response = match result {
		Ok(transaction_request) => {
			ResolveTransactionRequestResponse {
				success:             true,
				errors:              vec![],
				transaction_request: Some(transaction_request),
			}
		},
		Err(e) => {
			ResolveTransactionRequestResponse {
				success:             false,
				errors:              failure_to_mutation_errors(e),
				transaction_request: None,
			}
		},
	};

	Ok(response)
}
