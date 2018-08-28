use bigdecimal::BigDecimal;
use chrono::NaiveDateTime;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;
use models::schema::accounts;
use validator::Validate;

#[derive(Queryable, GraphQLObject)]
pub struct Account {
	pub id: i32,
	pub created_at: NaiveDateTime,
	pub user_id: i32,
	pub name: String,
	pub yearly_interest: BigDecimal,
}

#[derive(Insertable, Validate)]
#[table_name = "accounts"]
pub struct AccountAttrs {
	pub user_id: i32,
	pub name: String,
	pub yearly_interest: BigDecimal,
}

// graphql_object!(Account: () |&self| {
//     field name() -> &str {
//         self.name.as_str()
//     }

//     field yearly_interest() -> f32 {
//         BigDecimal::to_f32(&self.yearly_interest).unwrap()
//     }
// });

impl Account {
	pub fn create(conn: &PgConnection, attrs: AccountAttrs) -> Result<Account, Error> {
		diesel::insert_into(accounts::dsl::accounts)
			.values(&attrs)
			.get_result(conn)
	}
}
