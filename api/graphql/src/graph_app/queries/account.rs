use bigdecimal::BigDecimal;
use bigdecimal::ToPrimitive;
use chrono::NaiveDateTime;
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

	field yearly_interest() -> f64 {
		BigDecimal::to_f64(&self.yearly_interest).unwrap()
	}

	field transactions(&executor, since: NaiveDateTime) -> Vec<Transaction> {
		let ctx = &executor.context();
		let conn = &ctx.conn;

		// We can access via account or accounts queries
		// We assume that authorisation already happened in either of those
		Transaction::find_by_account_id(conn, self.id, since)
			.unwrap_or(vec![])
	}
});
