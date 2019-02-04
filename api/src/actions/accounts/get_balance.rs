use super::calculate_interest;
use crate::models::{account::Account, cents::Cents, transaction::Transaction};
use chrono::prelude::*;
use diesel::pg::PgConnection;
use failure::Error;

pub fn call(conn: &PgConnection, account_id: i32) -> Result<i64, Error> {
	let account = Account::find(&conn, account_id)?;

	let previous_transaction_result = Transaction::find_last_by_account_id(&conn, account_id);

	match previous_transaction_result {
		Ok(previous_transaction) => {
			let now = Utc::now().naive_utc();

			// Calculate the interest on the fly
			let Cents(interest) = calculate_interest::call(
				previous_transaction.balance,
				&account.yearly_interest,
				previous_transaction.created_at,
				now,
			)?;

			let Cents(cents) = previous_transaction.balance;

			Ok(cents + interest)
		},
		Err(_) => Ok(0),
	}
}
