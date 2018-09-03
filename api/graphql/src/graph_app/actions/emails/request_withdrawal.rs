use diesel::pg::PgConnection;
use failure::Error;

use graph_common::actions::emails::send;
use models::account::Account;
use models::cents::Cents;
use models::transaction_request::TransactionRequest;
use models::user::User;
use shared::email_kinds::EmailKind;

pub fn call(conn: &PgConnection, transaction_request: &TransactionRequest) -> Result<(), Error> {
	let account = Account::find(&conn, transaction_request.account_id)?;
	let user = User::find(&conn, account.user_id)?;

	let Cents(cents) = transaction_request.amount;

	let email_kind = EmailKind::RequestWithdrawal {
		email: user.email,
		amount_in_cents: cents,
	};

	send::call(&email_kind)
}
