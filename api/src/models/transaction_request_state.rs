use diesel::deserialize::{self, FromSql};
use diesel::pg::Pg;
use diesel::serialize::{self, IsNull, Output, ToSql};
use diesel::sql_types::*;
use std::io;

pub const APPROVED: &[u8] = b"APPROVED";
pub const PENDING: &[u8] = b"PENDING";
pub const REJECTED: &[u8] = b"REJECTED";

#[derive(Debug, Copy, Clone, FromSqlRow, AsExpression, GraphQLEnum, PartialEq)]
#[sql_type = "Varchar"]
pub enum TransactionRequestState {
	Pending,
	Approved,
	Rejected,
}

impl ToSql<Text, Pg> for TransactionRequestState {
	fn to_sql<W: io::Write>(&self, out: &mut Output<W, Pg>) -> serialize::Result {
		let _v = match *self {
			TransactionRequestState::Approved => out.write_all(APPROVED)?,
			TransactionRequestState::Pending => out.write_all(PENDING)?,
			TransactionRequestState::Rejected => out.write_all(REJECTED)?,
		};
		Ok(IsNull::No)
	}
}

impl FromSql<Text, Pg> for TransactionRequestState {
	fn from_sql(bytes: Option<&[u8]>) -> deserialize::Result<Self> {
		match not_none!(bytes) {
			APPROVED => Ok(TransactionRequestState::Approved),
			PENDING => Ok(TransactionRequestState::Pending),
			REJECTED => Ok(TransactionRequestState::Rejected),
			_ => Err("Unrecognized enum variant".into()),
		}
	}
}
