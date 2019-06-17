use diesel::pg::PgConnection;
use failure::Error;

use crate::{
	actions::emails::send,
	models::{
		account::Account, cents::Cents, 
		transaction_request::TransactionRequest, user::User,
	},
};
use shared::emails::{Email, EmailKind};

pub fn call(conn: &PgConnection, transaction_request: &TransactionRequest) -> Result<(), Error> {
	let account = Account::find(&conn, transaction_request.account_id)?;
	let user = User::find(&conn, account.user_id)?;

	let email_address = match user.email {
		Some(email) => email,
		None => return Ok(()),
	};

	let Cents(cents) = transaction_request.amount;

	let email_kind = EmailKind::RequestWithdrawal {
		name:            user.name,
		amount_in_cents: cents,
	};

	let email = Email {
		to: email_address.to_string(),
		kind: email_kind,
	};

	send::call(&email)
}
