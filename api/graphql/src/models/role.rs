use diesel::deserialize::{self, FromSql};
use diesel::pg::Pg;
use diesel::serialize::{self, IsNull, Output, ToSql};
use diesel::sql_types::*;
use std::io;

pub const ADMIN: &[u8] = b"ADMIN";
pub const INVESTOR: &[u8] = b"INVESTOR";

#[derive(Debug, Copy, Clone, FromSqlRow, AsExpression, GraphQLEnum, PartialEq, Deserialize, Serialize)]
#[sql_type = "Varchar"]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum Role {
	Admin,
	Investor,
}

impl ToSql<Text, Pg> for Role {
	fn to_sql<W: io::Write>(&self, out: &mut Output<W, Pg>) -> serialize::Result {
		let _v = match *self {
			Role::Admin => out.write_all(ADMIN)?,
			Role::Investor => out.write_all(INVESTOR)?,
		};
		Ok(IsNull::No)
	}
}

impl FromSql<Text, Pg> for Role {
	fn from_sql(bytes: Option<&[u8]>) -> deserialize::Result<Self> {
		match not_none!(bytes) {
			ADMIN => Ok(Role::Admin),
			INVESTOR => Ok(Role::Investor),
			_ => Err("Unrecognized enum variant".into()),
		}
	}
}
