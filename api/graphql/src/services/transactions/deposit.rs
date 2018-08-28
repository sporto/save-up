use diesel::pg::PgConnection;
use failure::Error;
use models::cents::Cents;
use models::transactions::{Transaction, TransactionAttrs, TransactionKind};

#[derive(GraphQLInputObject, Clone)]
pub struct DepositInput {
	account_id: i32,
	amount: Cents,
}

pub fn call(conn: &PgConnection, input: DepositInput) -> Result<Transaction, Error> {
	let attrs = TransactionAttrs {
		account_id: input.account_id,
		kind: TransactionKind::Deposit,
		amount: input.amount,
	};

	Transaction::create(conn, attrs).map_err(|e| format_err!("{}", e))
}
