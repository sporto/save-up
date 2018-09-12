use bigdecimal::BigDecimal;
use chrono::NaiveDateTime;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;
use models::schema::accounts;
use validator::Validate;

#[derive(Queryable)]
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
