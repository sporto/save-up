use chrono::NaiveDateTime;
use diesel;
use diesel::backend::Backend;
use diesel::deserialize::{self, FromSql};
use diesel::pg::Pg;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;
use diesel::serialize::{self, IsNull, Output, ToSql};
use diesel::sql_types::*;
use juniper::Value;
use models::cents::Cents;
use models::schema::transactions;
use std::io;
use validator::Validate;

#[derive(Queryable, GraphQLObject, Clone)]
pub struct Transaction {
	pub id: i32,
	pub created_at: NaiveDateTime,
	pub account_id: i32,
	pub kind: TransactionKind,
	pub amount: Cents,
}

#[derive(Debug, Copy, Clone, FromSqlRow, AsExpression, GraphQLEnum, PartialEq)]
#[sql_type = "Varchar"]
pub enum TransactionKind {
	Deposit,
}

impl ToSql<Text, Pg> for TransactionKind {
	fn to_sql<W: io::Write>(&self, out: &mut Output<W, Pg>) -> serialize::Result {
		let _v = match *self {
			TransactionKind::Deposit => out.write_all(b"DEPOSIT")?,
		};
		Ok(IsNull::No)
	}
}

impl FromSql<Text, Pg> for TransactionKind {
	fn from_sql(bytes: Option<&[u8]>) -> deserialize::Result<Self> {
		match not_none!(bytes) {
			b"DEPOSIT" => Ok(TransactionKind::Deposit),
			_ => Err("Unrecognized enum variant".into()),
		}
	}
}

#[derive(Insertable, Validate, AsExpression)]
#[table_name = "transactions"]
pub struct TransactionAttrs {
	pub account_id: i32,
	pub kind: TransactionKind,
	pub amount: Cents,
}

impl Transaction {
	pub fn create(conn: &PgConnection, attrs: TransactionAttrs) -> Result<Transaction, Error> {
		diesel::insert_into(transactions::dsl::transactions)
			.values(&attrs)
			.get_result(conn)
	}
}
