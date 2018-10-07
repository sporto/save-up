use diesel::deserialize::{self, FromSql};
use diesel::pg::Pg;
use diesel::serialize::{self, IsNull, Output, ToSql};
use diesel::sql_types::*;
use std::io;

pub const DEPOSIT: &[u8] = b"DEPOSIT";
pub const WITHDRAWAL: &[u8] = b"WITHDRAWAL";
pub const INTEREST: &[u8] = b"INTEREST";

#[derive(Debug, Copy, Clone, FromSqlRow, AsExpression, GraphQLEnum, PartialEq)]
#[sql_type = "Varchar"]
pub enum TransactionKind {
	Deposit,
	Withdrawal,
	Interest,
}

impl ToSql<Text, Pg> for TransactionKind {
	fn to_sql<W: io::Write>(&self, out: &mut Output<W, Pg>) -> serialize::Result {
		let _v = match *self {
			TransactionKind::Deposit => out.write_all(DEPOSIT)?,
			TransactionKind::Withdrawal => out.write_all(WITHDRAWAL)?,
			TransactionKind::Interest => out.write_all(INTEREST)?,
		};
		Ok(IsNull::No)
	}
}

impl FromSql<Text, Pg> for TransactionKind {
	fn from_sql(bytes: Option<&[u8]>) -> deserialize::Result<Self> {
		match not_none!(bytes) {
			DEPOSIT => Ok(TransactionKind::Deposit),
			WITHDRAWAL => Ok(TransactionKind::Withdrawal),
			INTEREST => Ok(TransactionKind::Interest),
			_ => Err("Unrecognized enum variant".into()),
		}
	}
}
