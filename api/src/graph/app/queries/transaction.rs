use chrono::NaiveDateTime;
use graph::AppContext;
use models::cents::Cents;
use models::transaction::{Transaction, TransactionKind};

graphql_object!(Transaction: AppContext |&self| {
	field id() -> i32 {
		self.id
	}

	field created_at() -> NaiveDateTime {
		self.created_at
	}

	field accountId() -> i32 {
		self.account_id
	}

	field kind() -> TransactionKind {
		self.kind
	}

	field amount_in_cents()-> f64 {
		let Cents(cents) = self.amount;
		cents as f64
	}

	field balance_in_cents()-> f64 {
		let Cents(cents) = self.balance;
		cents as f64
	}
});
