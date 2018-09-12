use chrono::NaiveDateTime;
use graph_app::context::AppContext;
use models::cents::Cents;
use models::transaction::{Transaction, TransactionKind};

graphql_object!(Transaction: AppContext |&self| {
	field id() -> i32 {
		self.id
	}

	field createdAt() -> NaiveDateTime {
		self.created_at
	}

	field accountId() -> i32 {
		self.account_id
	}

	field kind() -> TransactionKind {
		self.kind
	}

	field amountInCents()-> f64 {
		let Cents(cents) = self.amount;
		cents as f64
	}

	field balanceInCents()-> f64 {
		let Cents(cents) = self.balance;
		cents as f64
	}
});
