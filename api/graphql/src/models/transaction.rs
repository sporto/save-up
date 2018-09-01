use chrono::NaiveDateTime;
use diesel;
// use diesel::backend::Backend;
use diesel::deserialize::{self, FromSql};
use diesel::pg::Pg;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;
use diesel::serialize::{self, IsNull, Output, ToSql};
use diesel::sql_types::*;
// use juniper::Value;
use models::cents::Cents;
use models::schema::transactions;
use std::io;
use validator::Validate;

#[derive(Debug, Queryable, GraphQLObject, Clone, PartialEq)]
pub struct Transaction {
	pub id: i32,
	pub created_at: NaiveDateTime,
	pub account_id: i32,
	pub kind: TransactionKind,
	pub amount: Cents,
	pub balance: Cents,
}

#[derive(Debug, Copy, Clone, FromSqlRow, AsExpression, GraphQLEnum, PartialEq)]
#[sql_type = "Varchar"]
pub enum TransactionKind {
	Deposit,
	Withdrawal,
	Interest,
}

impl ToSql<Text, Pg> for TransactionKind {
	fn to_sql<W: io::Write>(&self, out: &mut Output<W, Pg>) -> serialize::Result {
		let _v = match *self {
			TransactionKind::Deposit => out.write_all(b"DEPOSIT")?,
			TransactionKind::Withdrawal => out.write_all(b"WITHDRAWAL")?,
			TransactionKind::Interest => out.write_all(b"INTEREST")?,
		};
		Ok(IsNull::No)
	}
}

impl FromSql<Text, Pg> for TransactionKind {
	fn from_sql(bytes: Option<&[u8]>) -> deserialize::Result<Self> {
		match not_none!(bytes) {
			b"DEPOSIT" => Ok(TransactionKind::Deposit),
			b"WITHDRAWAL" => Ok(TransactionKind::Withdrawal),
			b"INTEREST" => Ok(TransactionKind::Interest),
			_ => Err("Unrecognized enum variant".into()),
		}
	}
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
		transactions::table
			.filter(transactions::account_id.eq(account_id))
			.order_by(transactions::created_at.desc())
			.get_result(conn)
	}
}

#[cfg(test)]
pub mod factories {
	use super::*;
	// use bigdecimal::FromPrimitive;
	use models::account::Account;

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
