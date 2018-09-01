use diesel::deserialize::{self, FromSql};
use diesel::pg::Pg;
use diesel::serialize::{self, IsNull, Output, ToSql};
use diesel::sql_types::*;
use std::io;

pub const ROLE_ADMIN: &str = "ADMIN";
#[allow(dead_code)]
pub const ROLE_INVESTOR: &str = "INVESTOR";

#[derive(Debug, Copy, Clone, FromSqlRow, AsExpression, GraphQLEnum, PartialEq, Deserialize, Serialize)]
#[sql_type = "Varchar"]
pub enum Role {
	Admin,
	Investor,
}

impl ToSql<Text, Pg> for Role {
	fn to_sql<W: io::Write>(&self, out: &mut Output<W, Pg>) -> serialize::Result {
		let _v = match *self {
			Role::Admin => out.write_all(b"DEPOSIT")?,
			Role::Investor => out.write_all(b"WITHDRAWAL")?,
		};
		Ok(IsNull::No)
	}
}

impl FromSql<Text, Pg> for Role {
	fn from_sql(bytes: Option<&[u8]>) -> deserialize::Result<Self> {
		match not_none!(bytes) {
			b"DEPOSIT" => Ok(Role::Admin),
			b"WITHDRAWAL" => Ok(Role::Investor),
			_ => Err("Unrecognized enum variant".into()),
		}
	}
}
