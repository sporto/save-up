use diesel::data_types::Cents;
use diesel::pg::types::sql_types::Money;
use diesel::pg::PgConnection;
use failure::Error;
use juniper::{Executor, FieldResult};
use models::transactions::Transaction;

pub struct TransactionInput {
	account_id: i32,
	// amount: Money,
}

pub fn call(conn: &PgConnection, input: TransactionInput) -> Result<Transaction, Error> {
	Err(format_err!("foo"))
}
