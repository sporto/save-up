use diesel::pg::PgConnection;
use failure::Error;
use models::transactions::Transaction;

#[derive(GraphQLInputObject, Clone)]
pub struct DepositInput {
	account_id: i32,
}

pub fn call(conn: &PgConnection, input: DepositInput) -> Result<Transaction, Error> {
	Err(format_err!("foo"))
}
