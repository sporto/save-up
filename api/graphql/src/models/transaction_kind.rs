use diesel::deserialize::{self, FromSql};
use diesel::pg::Pg;
use diesel::serialize::{self, IsNull, Output, ToSql};
use diesel::sql_types::*;
use std::io;


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
			TransactionKind::Deposit => out.write_all(b"DEPOSIT")?,
			TransactionKind::Withdrawal => out.write_all(b"WITHDRAWAL")?,
			TransactionKind::Interest => out.write_all(b"INTEREST")?,
		};
		Ok(IsNull::No)
	}
}

impl FromSql<Text, Pg> for TransactionKind {
	fn from_sql(bytes: Option<&[u8]>) -> deserialize::Result<Self> {
		match not_none!(bytes) {
			b"DEPOSIT" => Ok(TransactionKind::Deposit),
			b"WITHDRAWAL" => Ok(TransactionKind::Withdrawal),
			b"INTEREST" => Ok(TransactionKind::Interest),
			_ => Err("Unrecognized enum variant".into()),
		}
	}
}
