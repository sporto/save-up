use diesel::pg::PgConnection;
use failure::Error;

use crate::{
	actions::emails::send,
	models::{
		account::Account, cents::Cents, 
		transaction::Transaction,
		user::User,
	},
};
use shared::emails::{Email, EmailKind};

pub fn call(conn: &PgConnection, transaction: &Transaction) -> Result<(), Error> {
	// Find the user
	let account = Account::find(&conn, transaction.account_id)?;
	let user = User::find(&conn, account.user_id)?;

	let email_address = match user.email {
		Some(email) => email,
		None => return Ok(()),
	};

	let Cents(cents) = transaction.amount;
	let Cents(balance) = transaction.balance;

	let email_kind = EmailKind::AcknowledgeWithdrawal {
		amount_in_cents:  cents,
		balance_in_cents: balance,
	};

	let email = Email {
		to: email_address.to_string(),
		kind: email_kind,
	};

	send::call(&email)
}
