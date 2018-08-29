use diesel::pg::PgConnection;
use failure::Error;
use models::account::Account;
use models::cents::Cents;
use models::transaction::{Transaction, TransactionAttrs, TransactionKind};
use services::accounts;

#[derive(GraphQLInputObject, Clone)]
pub struct DepositInput {
	account_id: i32,
	cents: i32,
}

pub fn call(conn: &PgConnection, input: DepositInput) -> Result<Transaction, Error> {
	// Fail if cents is negative
	if input.cents <= 0 {
		return Err(format_err!("Invalid amount"));
	}

	let current_balance = accounts::get_balance::call(&conn, input.account_id)?;

	let cents = input.cents as i64;

	let attrs = TransactionAttrs {
		account_id: input.account_id,
		kind: TransactionKind::Deposit,
		amount: Cents(cents),
		balance: Cents(cents + current_balance),
	};

	// TODO send an email to the account holder
	// Calculate running balance

	Transaction::create(conn, attrs).map_err(|e| format_err!("{}", e))
}

#[cfg(test)]
mod test {
	use super::*;
	use models;
	use utils::tests;

	#[test]
	fn it_creates_a_transaction() {
		tests::with_db(|conn| {
			let client = models::client::factories::client_attrs().save(conn);

			let user = models::user::factories::user_attrs(&client).save(conn);

			let account = models::account::factories::account_attrs(&user).save(conn);

			let input = DepositInput {
				account_id: account.id,
				cents: 200,
			};

			let transaction = call(conn, input).unwrap();

			assert_eq!(transaction.account_id, account.id);
			assert_eq!(transaction.amount, Cents(200));
			assert_eq!(transaction.kind, TransactionKind::Deposit);
		})
	}

	#[test]
	fn it_fails_with_negative_amount() {
		tests::with_db(|conn| {
			let client = models::client::factories::client_attrs().save(conn);

			let user = models::user::factories::user_attrs(&client).save(conn);

			let account = models::account::factories::account_attrs(&user).save(conn);

			let input = DepositInput {
				account_id: account.id,
				cents: -200,
			};

			let result = call(conn, input);

			assert!(result.is_err());
		})
	}
}
