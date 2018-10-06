use actions::emails::request_withdrawal;
use diesel::pg::PgConnection;
use failure::Error;
use models::cents::Cents;
use models::transaction_kind::TransactionKind;
use models::transaction_request::{TransactionRequest, TransactionRequestAttrs};
use models::transaction_request_state::TransactionRequestState;

#[derive(GraphQLInputObject, Clone)]
pub struct RequestWithdrawalInput {
	pub account_id: i32,
	pub cents: i32,
}

pub fn call(
	conn: &PgConnection,
	input: RequestWithdrawalInput,
) -> Result<TransactionRequest, Error> {
	// Fail if cents is negative
	if input.cents <= 0 {
		return Err(format_err!("Invalid amount"));
	}

	let amount = input.cents as i64;

	let attrs = TransactionRequestAttrs {
		account_id: input.account_id,
		kind: TransactionKind::Withdrawal,
		amount: Cents(amount),
		state: TransactionRequestState::Pending,
	};

	let transaction_request =
		TransactionRequest::create(conn, attrs).map_err(|e| format_err!("{}", e))?;

	// Send email
	request_withdrawal::call(&conn, &transaction_request)?;

	Ok(transaction_request)
}
