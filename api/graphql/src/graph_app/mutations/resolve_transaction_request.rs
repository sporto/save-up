use juniper::{Executor, FieldError, FieldResult};

use graph_app::actions::accounts::authorise;
use graph_app::actions::transactions::resolve_transaction_request;
pub use graph_app::actions::transactions::resolve_transaction_request::ResolveTransactionRequestInput;
use graph_app::context::AppContext;
use graph_common::mutations::failure_to_mutation_errors;
use graph_common::mutations::MutationError;
use models::transaction_request::TransactionRequest;

#[derive(GraphQLObject, Clone)]
pub struct ResolveTransactionRequestResponse {
	success: bool,
	errors: Vec<MutationError>,
	transaction_request: Option<TransactionRequest>,
}

pub fn call(
	executor: &Executor<AppContext>,
	input: ResolveTransactionRequestInput,
) -> FieldResult<ResolveTransactionRequestResponse> {
	let context = executor.context();
	let conn = &context.conn;
	let current_user = &context.user;

	// Authorise
	let transaction_request = TransactionRequest::find(&conn, input.transaction_request_id)?;

	let can = authorise::can_admin(&conn, transaction_request.account_id, &current_user)?;

	if can == false {
		return Err(FieldError::from("Unauthorised"));
	}

	let result = resolve_transaction_request::call(&context.conn, input);

	let response = match result {
		Ok(transaction_request) => ResolveTransactionRequestResponse {
			success: true,
			errors: vec![],
			transaction_request: Some(transaction_request),
		},
		Err(e) => ResolveTransactionRequestResponse {
			success: false,
			errors: failure_to_mutation_errors(e),
			transaction_request: None,
		},
	};

	Ok(response)
}
