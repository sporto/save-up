use super::calculate_interest;
use crate::models::{
	account::Account,
	cents::Cents,
	transaction::{Transaction, TransactionAttrs, TransactionKind},
};
use chrono::{prelude::*, Duration};
use diesel::{pg::PgConnection, result::Error as DieselError};
use failure::Error;

#[derive(Debug, PartialEq)]
pub enum PayInterestResponse {
	NotNeeded,
	Paid(Transaction),
}

pub fn call(conn: &PgConnection, account_id: i32) -> Result<PayInterestResponse, Error> {
	let account = Account::find(&conn, account_id)?;

	let previous_transaction_result = Transaction::find_last_by_account_id(&conn, account_id);

	// If there is no previous transaction, then there is no interest to pay
	let previous_transaction = match previous_transaction_result {
		Ok(t) => t,
		Err(e) => {
			match e {
				DieselError::NotFound => return Ok(PayInterestResponse::NotNeeded),
				_ => return Err(format_err!("{}", e)),
			}
		},
	};

	// println!("{}", previous_transaction);

	// If the previous transaction was in the last 1 day, then there is no interest to pay
	let now = Utc::now().naive_utc();

	let threshold = now - Duration::days(1);

	if previous_transaction.created_at > threshold {
		return Ok(PayInterestResponse::NotNeeded);
	}

	// Calculate the interest
	let Cents(interest) = calculate_interest::call(
		previous_transaction.balance,
		&account.yearly_interest,
		previous_transaction.created_at,
		now,
	)?;

	let Cents(previous_balance) = previous_transaction.balance;

	let new_balance = Cents(previous_balance + interest);

	// Pay interest
	let attrs = TransactionAttrs {
		account_id: account_id,
		kind:       TransactionKind::Interest,
		amount:     Cents(interest),
		balance:    new_balance,
	};

	Transaction::create(conn, attrs)
		.map(|t| PayInterestResponse::Paid(t))
		.map_err(|e| format_err!("{}", e))
}

#[cfg(test)]
mod tests {
	use super::*;
	use diesel::{self, prelude::*};
	use crate::models::{self, schema::transactions};
	use crate::utils::tests;

	#[test]
	fn it_doesnt_do_anything_if_there_is_no_previous_transaction() {
		tests::with_db(|conn| {
			let (account, _, _) = tests::account(&conn);

			let response = call(conn, account.id).unwrap();
			let expected = PayInterestResponse::NotNeeded;

			assert_eq!(response, expected);
		})
	}

	#[test]
	fn it_doesnt_pay_if_previous_withing_threshold() {
		tests::with_db(|conn| {
			let client = models::client::factories::client_attrs().save(conn);
			let user = models::user::factories::user_attrs(&client).save(conn);
			let account = models::account::factories::account_attrs(&user).save(conn);
			let _transaction =
				models::transaction::factories::transaction_attrs(&account).save(conn);

			let response = call(conn, account.id).unwrap();
			let expected = PayInterestResponse::NotNeeded;

			assert_eq!(response, expected);
		})
	}

	#[test]
	fn it_pays_interest() {
		tests::with_db(|conn| {
			let client = models::client::factories::client_attrs().save(conn);
			let user = models::user::factories::user_attrs(&client).save(conn);
			let account = models::account::factories::account_attrs(&user).save(conn);

			let transaction =
				models::transaction::factories::transaction_attrs(&account).save(conn);

			// Make the transaction one day old
			let day_ago = Utc::now().naive_utc() - Duration::days(1) - Duration::hours(1);

			// Cannot find this
			diesel::update(transactions::table.filter(transactions::id.eq(transaction.id)))
				.set(transactions::created_at.eq(day_ago))
				.execute(conn)
				.unwrap();

			let response = call(conn, account.id).unwrap();

			match response {
				PayInterestResponse::NotNeeded => panic!("Should not be NotNeeded"),
				PayInterestResponse::Paid(returned_transaction) => {
					assert_eq!(returned_transaction.kind, TransactionKind::Interest);
				},
			}
		})
	}
}
