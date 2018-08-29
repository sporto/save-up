use chrono::prelude::*;
use chrono::Duration;
use diesel::pg::PgConnection;
use failure::Error;
use models::cents::Cents;
use models::transaction::{Transaction, TransactionAttrs, TransactionKind};

pub enum PayInterestResponse {
	NotNeeded,
	Paid(Transaction),
}

pub fn call(conn: &PgConnection, account_id: i32) -> Result<PayInterestResponse, Error> {
	let previous_transaction_result = Transaction::find_last_by_account_id(&conn, account_id);

	// If there is no previous transaction, then there is no interest to pay
	let previous_transaction = match previous_transaction_result {
		Ok(t) => t,
		Err(_) => return Ok(PayInterestResponse::NotNeeded),
	};

	// If the previous transaction was in the last 1 day, then there is no interest to pay
	let now = Utc::now().naive_utc();

	let threshold = now - Duration::days(1);

	if previous_transaction.created_at > threshold {
		return Ok(PayInterestResponse::NotNeeded);
	}

	// Calculate the interest
	let interest = 123;

	let Cents(previous_balance) = previous_transaction.balance;

	let new_balance = Cents(previous_balance + interest);

	// Pay interest
	let attrs = TransactionAttrs {
		account_id: account_id,
		kind: TransactionKind::Interest,
		amount: Cents(interest),
		balance: new_balance,
	};

	Transaction::create(conn, attrs)
		.map(|t| PayInterestResponse::Paid(t))
		.map_err(|e| format_err!("{}", e))
}
