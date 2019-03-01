use crate::models::{account::Account, cents::Cents, schema::transaction_requests};
pub use crate::models::{
	transaction_kind::TransactionKind, transaction_request_state::TransactionRequestState,
};
use chrono::NaiveDateTime;
use diesel::{self, pg::PgConnection, prelude::*, result::Error};
use validator::Validate;

#[derive(Identifiable, Debug, Queryable, Associations, Clone, PartialEq)]
#[belongs_to(Account)]
#[table_name = "transaction_requests"]
pub struct TransactionRequest {
	pub id:         i32,
	pub created_at: NaiveDateTime,
	pub account_id: i32,
	pub kind:       TransactionKind,
	pub amount:     Cents,
	pub state:      TransactionRequestState,
}

#[derive(Insertable, Validate, AsExpression)]
#[table_name = "transaction_requests"]
pub struct TransactionRequestAttrs {
	pub account_id: i32,
	pub kind:       TransactionKind,
	pub amount:     Cents,
	pub state:      TransactionRequestState,
}

impl TransactionRequest {
	#[allow(dead_code)]
	pub fn create(
		conn: &PgConnection,
		attrs: TransactionRequestAttrs,
	) -> Result<TransactionRequest, Error> {
		diesel::insert_into(transaction_requests::dsl::transaction_requests)
			.values(&attrs)
			.get_result(conn)
	}

	#[allow(dead_code)]
	pub fn find(conn: &PgConnection, id: i32) -> Result<TransactionRequest, Error> {
		transaction_requests::table.find(id).get_result(conn)
	}
}
