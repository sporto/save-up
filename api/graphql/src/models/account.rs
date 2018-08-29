use bigdecimal::BigDecimal;
use bigdecimal::ToPrimitive;
use chrono::NaiveDateTime;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;
// use diesel::sql_types::Numeric;
// use diesel::pg::data_types::PgNumeric;
use models::schema::accounts;
use validator::Validate;
use models::cents::Cents;

#[derive(Queryable)]
pub struct Account {
	pub id: i32,
	pub created_at: NaiveDateTime,
	pub user_id: i32,
	pub name: String,
	pub balance: Cents,
	pub yearly_interest: BigDecimal,
}

#[derive(Insertable, Validate)]
#[table_name = "accounts"]
pub struct AccountAttrs {
	pub user_id: i32,
	pub name: String,
	pub balance: Cents,
	pub yearly_interest: BigDecimal,
}

graphql_object!(Account: () |&self| {
    field name() -> &str {
        self.name.as_str()
    }

    field yearly_interest() -> f64 {
        BigDecimal::to_f64(&self.yearly_interest).unwrap()
    }
});

impl Account {
	pub fn create(conn: &PgConnection, attrs: AccountAttrs) -> Result<Account, Error> {
		diesel::insert_into(accounts::dsl::accounts)
			.values(&attrs)
			.get_result(conn)
	}

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

	pub fn account_attrs(user: &User) -> AccountAttrs {
		let yearly_interest = BigDecimal::from_f32(10.5).unwrap();

		AccountAttrs {
			user_id: user.id,
			name: user.clone().name,
			balance: Cents(0),
			yearly_interest: yearly_interest,
		}
	}

	impl AccountAttrs {
		pub fn save(self, conn: &PgConnection) -> Account {
			Account::create(conn, self).unwrap()
		}
	}

}
