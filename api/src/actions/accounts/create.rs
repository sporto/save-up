use bigdecimal::BigDecimal;
use bigdecimal::FromPrimitive;
use diesel::pg::PgConnection;
use failure::Error;

use models::account::{Account, AccountAttrs, Kind, State, DEFAULT_YEARLY_INTEREST};
use models::user::User;

pub fn call(conn: &PgConnection, user: &User) -> Result<Account, Error> {
	let yearly_interest = BigDecimal::from_u8(DEFAULT_YEARLY_INTEREST).unwrap();

	let attrs = AccountAttrs {
		user_id: user.clone().id,
		name: user.clone().name,
		yearly_interest,
		kind: Kind::Savings,
		state: State::Active,
	};

	Account::create(conn, attrs).map_err(|e| format_err!("{}", e))
}
