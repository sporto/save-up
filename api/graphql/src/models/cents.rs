use juniper::Value;
// use diesel::backend::Backend;
use diesel::pg::Pg;
use diesel::deserialize::{self,FromSql};
use diesel::serialize::{self,Output, ToSql};
use std::io;
use diesel::sql_types::{BigInt,Money};

// #[sql_type = "Money"]
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, FromSqlRow, AsExpression)]
#[sql_type = "Money"]
pub struct Cents(pub i64);

impl ToString for Cents {
	fn to_string(&self) -> String {
		let Cents(cents) = self;
		format!("{}", cents)
	}
}

// impl<DB: Backend> ToSql<i64, DB> for Cents {
// 	fn to_sql<W>(&self, out: &mut Output<W, DB>) -> serialize::Result
// 	where
// 		W: io::Write,
// 	{
// 		let Cents(cents) = self;
// 		i64::to_sql(cents, out)
// 	}
// }

// impl<DB: Backend> FromSql<i64, DB> for Cents {
// 	fn from_sql(bytes: Option<&DB::RawValue>) -> deserialize::Result<Self> {
// 		let v = (bytes);
// 		Ok(Cents(9999))
// 	}
// }

impl FromSql<Money, Pg> for Cents {
    fn from_sql(bytes: Option<&[u8]>) -> deserialize::Result<Self> {
        FromSql::<BigInt, Pg>::from_sql(bytes).map(Cents)
    }
}

impl ToSql<Money, Pg> for Cents {
    fn to_sql<W: io::Write>(&self, out: &mut Output<W, Pg>) -> serialize::Result {
        ToSql::<BigInt, Pg>::to_sql(&self.0, out)
    }
}


graphql_scalar!(Cents {
	description: "Cents"
 
	resolve(&self) -> Value {
		Value::string(self.to_string())
	}

	 from_input_value(v: &InputValue) -> Option<Cents> {
		v.as_string_value()
			.and_then(|s| s.parse::<i64>().ok() )
			.map(|n| Cents(n))
	}
});
