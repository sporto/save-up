use crate::{
	actions::emails::resolve_transaction_request,
	models::{
		schema as db, transaction_request::TransactionRequest,
		transaction_request_state::TransactionRequestState,
	},
};
use diesel::{self, pg::PgConnection, prelude::*};
use failure::Error;

#[derive(GraphQLInputObject, Clone)]
pub struct ResolveTransactionRequestInput {
	pub transaction_request_id: i32,
	pub outcome:                TransactionRequestState,
}

pub fn call(
	conn: &PgConnection,
	input: ResolveTransactionRequestInput,
) -> Result<TransactionRequest, Error> {
	let filter = db::transaction_requests::id.eq(input.transaction_request_id);

	let transaction_request = diesel::update(db::transaction_requests::table.filter(filter))
		.set(db::transaction_requests::state.eq(input.outcome))
		.get_result(conn)?;

	// Send email
	resolve_transaction_request::call(&conn, &transaction_request)?;

	Ok(transaction_request)
}
