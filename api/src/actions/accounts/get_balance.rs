use diesel::pg::PgConnection;
use failure::Error;
use models::transaction::Transaction;
use models::cents::Cents;

pub fn call(conn: &PgConnection, account_id: i32) -> Result<i64, Error> {
	let previous_transaction = Transaction::find_last_by_account_id(&conn, account_id);

	match previous_transaction {
		Ok(t) => {
			let Cents(cents) = t.balance;
			Ok(cents)
		},
		Err(_) => Ok(0),
	}
}
