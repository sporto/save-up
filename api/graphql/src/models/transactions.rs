use chrono::NaiveDateTime;
use diesel;
use diesel::backend::Backend;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;
use diesel::sql_types::*;
use models::cents::Cents;
use models::schema::transactions;
use std::io;
use validator::Validate;

#[derive(Queryable, GraphQLObject, Clone)]
pub struct Transaction {
	pub id: i32,
	pub created_at: NaiveDateTime,
	pub account_id: i32,
	// pub kind: TransactionKind,
	pub amount: Cents,
}

// #[derive(Debug, Copy, Clone, FromSqlRow, AsExpression)]
// pub enum TransactionKind {
// 	Deposit,
// }

// impl<DB: Backend> ToSql<String, DB> for TransactionKind {
// 	fn to_sql<W>(&self, out: &mut Output<W, DB>) -> serialize::Result
// 	where
// 		W: io::Write,
// 	{
// 		let v = match *self {
// 			TransactionKind::Deposit => "DEPOSIT",
// 		};
// 		v.to_sql(out)
// 	}
// }

// impl<DB: Backend> FromSql<String, DB> for TransactionKind {
// 	fn from_sql(bytes: Option<&DB::RawValue>) -> deserialize::Result<Self> {
// 		let v = (bytes);
// 		Ok(match v {
// 			"DEPOSIT" => TransactionKind::Deposit,
// 			_ => return Err("Unknown kind".into()),
// 		})
// 	}
// }

#[derive(Insertable, Validate, AsExpression)]
#[table_name = "transactions"]
pub struct TransactionAttrs {
	pub account_id: i32,
	// pub kind: TransactionKind,
	pub amount: Cents,
}

impl Transaction {
	pub fn create(conn: &PgConnection, attrs: TransactionAttrs) -> Result<Transaction, Error> {
		// diesel::insert_into(transactions::dsl::transactions)
		// 	.values(&attrs)
		// 	.get_result(conn)
		Err(Error::NotFound)
	}
}
