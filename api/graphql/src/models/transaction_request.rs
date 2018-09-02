use chrono::NaiveDateTime;
use diesel;
// use diesel::pg::Pg;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;
use models::cents::Cents;
use models::schema::transaction_requests;
pub use models::transaction_kind::TransactionKind;
pub use models::transaction_request_state::TransactionRequestState;
use validator::Validate;

#[derive(Debug, Queryable, GraphQLObject, Clone, PartialEq)]
pub struct TransactionRequest {
	pub id: i32,
	pub created_at: NaiveDateTime,
	pub account_id: i32,
	pub kind: TransactionKind,
	pub amount: Cents,
	pub state: TransactionRequestState,
}

#[derive(Insertable, Validate, AsExpression)]
#[table_name = "transaction_requests"]
pub struct TransactionRequestAttrs {
	pub account_id: i32,
	pub kind: TransactionKind,
	pub amount: Cents,
	pub state: TransactionRequestState,
}
