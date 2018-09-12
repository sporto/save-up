use chrono::NaiveDateTime;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;
use models::cents::Cents;
use models::schema::transactions;
pub use models::transaction_kind::TransactionKind;
use validator::Validate;

#[derive(Debug, Queryable, Clone, PartialEq)]
pub struct Transaction {
	pub id: i32,
	pub created_at: NaiveDateTime,
	pub account_id: i32,
	pub kind: TransactionKind,
	pub amount: Cents,
	pub balance: Cents,
}

#[derive(Insertable, Validate, AsExpression)]
#[table_name = "transactions"]
pub struct TransactionAttrs {
	pub account_id: i32,
	pub kind: TransactionKind,
	pub amount: Cents,
	pub balance: Cents,
}

impl Transaction {
	#[allow(dead_code)]
	pub fn create(conn: &PgConnection, attrs: TransactionAttrs) -> Result<Transaction, Error> {
		diesel::insert_into(transactions::dsl::transactions)
			.values(&attrs)
			.get_result(conn)
	}

	#[allow(dead_code)]
	pub fn find_last_by_account_id(
		conn: &PgConnection,
		account_id: i32,
	) -> Result<Transaction, Error> {
		let filter = transactions::account_id.eq(account_id);

		transactions::table
			.filter(filter)
			.order_by(transactions::created_at.desc())
			.get_result(conn)
	}

	#[allow(dead_code)]
	pub fn find_by_account_id(
		conn: &PgConnection,
		account_id: i32,
		since: NaiveDateTime,
	) -> Result<Vec<Transaction>, Error> {
		let filter = transactions::account_id
			.eq(account_id)
			.and(transactions::created_at.ge(since));

		transactions::table
			.filter(filter)
			.order_by(transactions::created_at.asc())
			.get_results(conn)
	}
}

#[cfg(test)]
pub mod factories {
	use super::*;
	// use bigdecimal::FromPrimitive;
	use models::account::Account;

	#[allow(dead_code)]
	pub fn transaction_attrs(account: &Account) -> TransactionAttrs {
		let balance = Cents(0);

		TransactionAttrs {
			account_id: account.id,
			kind: TransactionKind::Deposit,
			amount: Cents(0),
			balance: balance,
		}
	}

	impl TransactionAttrs {
		pub fn save(self, conn: &PgConnection) -> Transaction {
			Transaction::create(conn, self).unwrap()
		}

		pub fn balance(mut self, balance: i64) -> TransactionAttrs {
			self.balance = Cents(balance);
			self
		}
	}

	impl Transaction {
		pub fn delete_all(conn: &PgConnection) -> Result<usize, Error> {
			diesel::delete(transactions::table).execute(conn)
		}
	}

}
