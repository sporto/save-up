use diesel::pg::PgConnection;
use failure::Error;

use crate::{
	actions::emails::send,
	models::{
		account::Account, cents::Cents, email_kinds::EmailKind,
		transaction_request::TransactionRequest, user::User,
	},
};

pub fn call(conn: &PgConnection, transaction_request: &TransactionRequest) -> Result<(), Error> {
	let account = Account::find(&conn, transaction_request.account_id)?;
	let user = User::find(&conn, account.user_id)?;

	let email = match user.email {
		Some(email) => email,
		None => return Ok(()),
	};

	let Cents(cents) = transaction_request.amount;

	let email_kind = EmailKind::RequestWithdrawal {
		email:           email,
		name:            user.name,
		amount_in_cents: cents,
	};

	send::call(&email_kind)
}
