use chrono_tz::America;
use chrono_tz::Australia;
use graph_app::context::AppContext;
use juniper::{FieldError, FieldResult};
// use models::client::*;
use diesel::prelude::*;
use models::account::Account;
use models::role::Role;
use models::schema as db;
use models::user::User;

pub struct AppQueryRoot;

graphql_object!(AppQueryRoot: AppContext |&self| {

	field apiVersion() -> &str {
		"1.0"
	}

	// Only an admin can request this
	field admin(&executor) -> FieldResult<AdminViewer> {
		// TODO fail if not admin

	 	Ok(AdminViewer {
			investors: vec![],
			b: 1,
	 	})
	}

	field timezones(&executor) -> FieldResult<Vec<String>> {
		let timezones = vec![
			format!("{:?}", Australia::Adelaide),
			format!("{:?}", Australia::Melbourne),
			format!("{:?}", Australia::Broken_Hill),
			format!("{:?}", America::Lima),
		];

		Ok(timezones)
	}
});

struct AdminViewer {
	investors: Vec<User>,
	b: i32,
}

graphql_object!(AdminViewer: AppContext |&self| {
	field investors(&executor) -> FieldResult<Vec<User>> {
		let context = &executor.context();
		let client_id = context.user.client_id;
		let conn = &context.conn;

		let is_investor = db::users::role.eq(Role::Investor);

		let filter = db::users
			::client_id.eq(client_id)
			.and(is_investor);

		db::users::table
			.filter(filter)
			.load::<User>(conn)
			.map_err(|e| FieldError::from(e))
	}

	field b() -> i32 {
		2
	}
});

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
