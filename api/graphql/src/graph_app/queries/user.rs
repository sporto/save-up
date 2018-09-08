use graph_app::context::AppContext;
use models::user::User;
use models::account::Account;
use juniper::{FieldError, FieldResult};
use models::schema as db;
use diesel::prelude::*;

// Move to model file
graphql_object!(User: AppContext |&self| {
	field id() -> &str {
		self.email.as_str()
	}

	field email() -> i32 {
		self.id
	}

	field name() -> &str {
		self.name.as_str()
	}

	field accounts(&executor) -> FieldResult<Vec<Account>> {
		let context = &executor.context();
		let client_id = context.user.client_id;
		let conn = &context.conn;

		let filter = db::accounts
			::user_id.eq(self.id);

		db::accounts::table
			.filter(filter)
			.load(conn)
			.map_err(|e| FieldError::from(e))
	}
});
