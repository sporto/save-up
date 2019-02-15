use juniper::Value;
use diesel::pg::Pg;
use diesel::deserialize::{self,FromSql};
use diesel::serialize::{self,Output,ToSql};
use std::io;
use diesel::sql_types::{BigInt,Money};
use std::ops::Sub;
use std::ops::Add;
use juniper::{ParseScalarResult};
use juniper::parser::{ParseError,ScalarToken,Token};

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, FromSqlRow, AsExpression)]
#[sql_type = "Money"]
pub struct Cents(pub i64);

impl ToString for Cents {
	fn to_string(&self) -> String {
		let Cents(cents) = self;
		format!("{}", cents)
	}
}

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

impl Sub for Cents {
	type Output = Cents;

	fn sub(self, Cents(other): Cents) -> Cents {
		let Cents(cents) = self;
		Cents(cents - other)
	}
}

impl Add for Cents {
	type Output = Cents;

	fn add(self, Cents(other): Cents) -> Cents {
		let Cents(cents) = self;
		Cents(cents + other)
	}
}


graphql_scalar!(Cents as "Cents" where Scalar = <S> {
	description: "Cents"
 
	resolve(&self) -> Value {
		Value::scalar(self.to_string())
	}

	from_input_value(v: &InputValue) -> Option<Cents> {
		v.as_scalar_value::<String>()
			.and_then(|s| s.parse::<i64>().ok() )
			.map(|n| Cents(n))
	}

	from_str<'a>(value: ScalarToken<'a>) -> ParseScalarResult<'a, S> {
		if let ScalarToken::String(value) = value {
			Ok(S::from(value.to_owned()))
		} else {
			Err(ParseError::UnexpectedToken(Token::Scalar(value)))
		}
	}
});
