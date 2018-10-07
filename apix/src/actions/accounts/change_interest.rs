use bigdecimal::BigDecimal;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use failure::Error;
use models::account::Account;
use models::schema as db;

pub fn call(conn: &PgConnection, account_id: i32, interest: BigDecimal) -> Result<Account, Error> {
	diesel::update(db::accounts::table.filter(db::accounts::id.eq(account_id)))
		.set(db::accounts::yearly_interest.eq(interest))
		.get_result(conn)
		.map_err(|e| format_err!("{}", e))
}
