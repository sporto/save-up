use actions;
use bigdecimal::{BigDecimal, ToPrimitive};
use chrono::{prelude::*, NaiveDateTime};
use graph::AppContext;
use juniper::{FieldError, FieldResult};
use models::{
	account::{Account, Kind, State},
	transaction::{Transaction, TransactionKind},
	user::User,
};

graphql_object!(Account: AppContext |&self| {
	field id() -> i32 {
		self.id
	}

	field user_id() -> i32 {
		self.user_id
	}

	field user(&executor) -> FieldResult<User> {
		let ctx = &executor.context();
		let conn = &ctx.conn;

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
		let conn = &ctx.conn;

		actions::accounts::get_balance::call(&conn, self.id)
			.unwrap_or(0) as f64
	}

	field yearly_interest() -> f64 {
		BigDecimal::to_f64(&self.yearly_interest).unwrap()
	}

	// since POSIX is in milliseconds
	// posix time should be kept in floats, because i32 will reset in the year 2038
	field transactions(&executor, since: f64) -> Vec<Transaction> {
		let ctx = &executor.context();
		let conn = &ctx.conn;

		// let since_in_secs = since / 1000.0;
		let since_dt = NaiveDateTime::from_timestamp(since as i64, 0);

		// We can access via account or accounts queries
		// We assume that authorisation already happened in either of those
		let transactions = Transaction::find_by_account_id(&conn, self.id, since_dt)
			.unwrap_or(vec![]);

		// Add a dummy transaction to reflect the latest interest
		let maybeFirst = transactions.first();

		match maybeFirst {
			None => transactions,
			Some(first) => {
				let current_balance = first.balance;

				let now = Utc::now().naive_utc();

				let interest_result = actions::accounts::calculate_interest::call(
					current_balance,
					&self.yearly_interest,
					first.created_at,
					now,
				);

				match interest_result {
					Ok(interest) => {
						let interest_transaction = Transaction {
							id: 0,
							created_at: now,
							account_id: self.id,
							kind: TransactionKind::Interest,
							amount: interest,
							balance: current_balance + interest,
						};

						transactions.push(interest_transaction);
					},
					Err(_) => ()
				};

				transactions
			}
		}
	}
});
