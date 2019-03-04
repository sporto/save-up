use crate::models::{account::Account, schema as db};
use bigdecimal::BigDecimal;
use diesel::{self, pg::PgConnection, prelude::*};
use failure::Error;
use super::pay_interest;

pub fn call(conn: &PgConnection, account_id: i32, interest: BigDecimal) -> Result<Account, Error> {
	// Create an interest transaction with the current interest
	pay_interest::call(&conn, account_id)?;

	diesel::update(db::accounts::table.filter(db::accounts::id.eq(account_id)))
		.set(db::accounts::yearly_interest.eq(interest))
		.get_result(conn)
		.map_err(|e| format_err!("{}", e))
}
