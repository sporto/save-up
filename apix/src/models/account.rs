use bigdecimal::BigDecimal;
use chrono::NaiveDateTime;
use diesel;
use diesel::deserialize::{self, FromSql};
use diesel::pg::Pg;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;
use diesel::serialize::{self, IsNull, Output, ToSql};
use diesel::sql_types::*;
use models::schema::accounts;
use models::user::User;
use std::io;
use validator::Validate;

pub const DEFAULT_YEARLY_INTEREST: u8 = 20;
pub const ACTIVE: &[u8] = b"ACTIVE";
pub const ARCHIVED: &[u8] = b"ARCHIVED";
pub const SAVINGS: &[u8] = b"SAVINGS";

#[derive(Queryable, Associations, Identifiable, Clone)]
#[belongs_to(User)]
#[table_name = "accounts"]
pub struct Account {
	pub id: i32,
	pub created_at: NaiveDateTime,
	pub user_id: i32,
	pub name: String,
	pub yearly_interest: BigDecimal,
	pub kind: Kind,
	pub state: State,
}

#[derive(Insertable, Validate)]
#[table_name = "accounts"]
pub struct AccountAttrs {
	pub user_id: i32,
	pub name: String,
	pub yearly_interest: BigDecimal,
	pub kind: Kind,
	pub state: State,
}

#[derive(
	Debug, Copy, Clone, FromSqlRow, AsExpression, GraphQLEnum, PartialEq, Deserialize, Serialize,
)]
#[sql_type = "Varchar"]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum Kind {
	Savings,
}

impl ToSql<Text, Pg> for Kind {
	fn to_sql<W: io::Write>(&self, out: &mut Output<W, Pg>) -> serialize::Result {
		let _v = match *self {
			Kind::Savings => out.write_all(SAVINGS)?,
		};
		Ok(IsNull::No)
	}
}

impl FromSql<Text, Pg> for Kind {
	fn from_sql(bytes: Option<&[u8]>) -> deserialize::Result<Self> {
		match not_none!(bytes) {
			SAVINGS => Ok(Kind::Savings),
			_ => Err("Unrecognized Kind variant".into()),
		}
	}
}

#[derive(
	Debug, Copy, Clone, FromSqlRow, AsExpression, GraphQLEnum, PartialEq, Deserialize, Serialize,
)]
#[sql_type = "Varchar"]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum State {
	Active,
	Archived,
}

impl ToSql<Text, Pg> for State {
	fn to_sql<W: io::Write>(&self, out: &mut Output<W, Pg>) -> serialize::Result {
		let _v = match *self {
			State::Active => out.write_all(ACTIVE)?,
			State::Archived => out.write_all(ARCHIVED)?,
		};
		Ok(IsNull::No)
	}
}

impl FromSql<Text, Pg> for State {
	fn from_sql(bytes: Option<&[u8]>) -> deserialize::Result<Self> {
		match not_none!(bytes) {
			ACTIVE => Ok(State::Active),
			ARCHIVED => Ok(State::Archived),
			_ => Err("Unrecognized State variant".into()),
		}
	}
}

impl Account {
	#[allow(dead_code)]
	pub fn create(conn: &PgConnection, attrs: AccountAttrs) -> Result<Account, Error> {
		diesel::insert_into(accounts::dsl::accounts)
			.values(&attrs)
			.get_result(conn)
	}

	#[allow(dead_code)]
	pub fn find(conn: &PgConnection, id: i32) -> Result<Account, Error> {
		accounts::table.filter(accounts::id.eq(id)).get_result(conn)
	}

	#[allow(dead_code)]
	pub fn find_by_user_id(conn: &PgConnection, id: i32) -> Result<Account, Error> {
		accounts::table
			.filter(accounts::user_id.eq(id))
			.get_result(conn)
	}
}

#[cfg(test)]
pub mod factories {
	use super::*;
	use bigdecimal::FromPrimitive;
	use models::user::User;

	#[allow(dead_code)]
	pub fn account_attrs(user: &User) -> AccountAttrs {
		let yearly_interest = BigDecimal::from_f32(10.5).unwrap();

		AccountAttrs {
			user_id: user.id,
			name: user.clone().name,
			yearly_interest: yearly_interest,
			kind: Kind::Savings,
			state: State::Active,
		}
	}

	impl AccountAttrs {
		pub fn save(self, conn: &PgConnection) -> Account {
			Account::create(conn, self).unwrap()
		}
	}

	impl Account {
		pub fn delete_all(conn: &PgConnection) -> Result<usize, Error> {
			diesel::delete(accounts::table).execute(conn)
		}
	}
}
