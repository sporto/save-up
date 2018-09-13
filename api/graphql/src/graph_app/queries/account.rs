use bigdecimal::BigDecimal;
use bigdecimal::ToPrimitive;
use chrono::NaiveDateTime;
use graph_app::actions;
use graph_app::context::AppContext;
use models::account::Account;
use models::transaction::Transaction;

graphql_object!(Account: AppContext |&self| {
	field id() -> i32 {
		self.id
	}

	field name() -> &str {
		self.name.as_str()
	}

	field balanceInCents(&executor) -> f64 {
		let ctx = &executor.context();
		let conn = &ctx.conn;

		actions::accounts::get_balance::call(conn, self.id)
			.unwrap_or(0) as f64
	}

	field yearlyInterest() -> f64 {
		BigDecimal::to_f64(&self.yearly_interest).unwrap()
	}

		// since POSIX in milliseconds
	// posix time should be kept in floats, because i32 will reset in the year 2038
	field transactions(&executor, since: f64) -> Vec<Transaction> {
		let ctx = &executor.context();
		let conn = &ctx.conn;

		// let since_in_secs = since / 1000.0;
		let since_dt = NaiveDateTime::from_timestamp(since as i64, 0);

		// We can access via account or accounts queries
		// We assume that authorisation already happened in either of those
		Transaction::find_by_account_id(conn, self.id, since_dt)
			.unwrap_or(vec![])
	}
});