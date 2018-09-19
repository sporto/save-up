use diesel::pg::PgConnection;
use failure::Error;
use graph_common::actions::emails::send;
use models::account::Account;
use models::cents::Cents;
use models::transaction::Transaction;
use models::user::User;
use shared::email_kinds::EmailKind;

pub fn call(conn: &PgConnection, transaction: &Transaction) -> Result<(), Error> {
	// Find the user
	let account = Account::find(&conn, transaction.account_id)?;
	let user = User::find(&conn, account.user_id)?;

	let email = match user.email {
		Some(email) => email,
		None => return Ok(()),
	};

	let Cents(cents) = transaction.amount;
	let Cents(balance) = transaction.balance;

	let email_kind = EmailKind::AcknowledgeDeposit {
		email: email,
		amount_in_cents: cents,
		balance_in_cents: balance,
	};

	send::call(&email_kind)
}
