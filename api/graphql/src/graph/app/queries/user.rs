use crate::{
	graph::AppContext,
	models::{account::Account, schema as db, user::User},
};
use diesel::prelude::*;
use juniper::{FieldError, FieldResult};

// Move to model file
graphql_object!(User: AppContext |&self| {
	field id() -> i32 {
		self.id
	}

	field email() -> Option<String> {
		self.clone().email
	}

	field name() -> &str {
		self.name.as_str()
	}

	field is_archived() -> bool {
		self.archived_at != None
	}

	field username() -> &str {
		self.username.as_str()
	}

	field accounts(&executor) -> FieldResult<Vec<Account>> {
		let ctx = &executor.context();
		let client_id = ctx.user.client_id;
		let conn = &ctx.conn;

		let filter = db::accounts
			::user_id.eq(self.id);

		db::accounts::table
			.filter(filter)
			.load(&*conn)
			.map_err(|e| FieldError::from(e))
	}
});
