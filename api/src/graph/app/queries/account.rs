use actions;
use bigdecimal::BigDecimal;
use bigdecimal::ToPrimitive;
use chrono::NaiveDateTime;
use graph::AppContext;
use juniper::{FieldError, FieldResult};
use models::account::{Account, Kind, State};
use models::transaction::Transaction;
use models::user::User;

graphql_object!(Account: AppContext |&self| {
	field id() -> i32 {
		self.id
	}

	field user_id() -> i32 {
		self.user_id
	}

	field user(&executor) -> FieldResult<User> {
		let ctx = &executor.context();
		let conn = ctx.pool.get().unwrap();

		User::find(&conn, self.user_id)
			.map_err(|e| FieldError::from(e))
	}

	field name() -> &str {
		self.name.as_str()
	}

	field kind() -> Kind {
		self.kind
	}

	field state() -> State {
		self.state
	}

	field balance_in_cents(&executor) -> f64 {
		let ctx = &executor.context();
		let conn = ctx.pool.get().unwrap();

		actions::accounts::get_balance::call(&conn, self.id)
			.unwrap_or(0) as f64
	}

	field yearly_interest() -> f64 {
		BigDecimal::to_f64(&self.yearly_interest).unwrap()
	}

	// since POSIX in milliseconds
	// posix time should be kept in floats, because i32 will reset in the year 2038
	field transactions(&executor, since: f64) -> Vec<Transaction> {
		let ctx = &executor.context();
		let conn = ctx.pool.get().unwrap();

		// let since_in_secs = since / 1000.0;
		let since_dt = NaiveDateTime::from_timestamp(since as i64, 0);

		// We can access via account or accounts queries
		// We assume that authorisation already happened in either of those
		Transaction::find_by_account_id(&conn, self.id, since_dt)
			.unwrap_or(vec![])
	}
});
