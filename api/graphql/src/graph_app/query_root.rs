use chrono_tz::America;
use chrono_tz::Australia;
use diesel::prelude::*;
use graph_app::actions;
use graph_app::context::AppContext;
// use graph_app::queries::*;
use juniper::{FieldError, FieldResult};
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
			account: None,
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
	account: Option<Account>,
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

	field account(&executor, id: i32) -> FieldResult<Account> {
		let ctx = &executor.context();
		let conn = &ctx.conn;
		let current_user = &ctx.user;

		// Authorise
		let can = actions::accounts::authorise::can_access(conn, id, current_user)?;

		if can == false {
			return Err(FieldError::from("Unauthorized"))
		};

		Account::find(conn, id)
			.map_err(|e| FieldError::from(e))
	}

});

struct InvestorViewer {
	accounts: Vec<Account>,
	account: Option<Account>,
}

graphql_object!(InvestorViewer: AppContext |&self| {

	field accounts(&executor) -> FieldResult<Vec<Account>> {
		let context = &executor.context();
		let user_id = context.user.id;
		let conn = &context.conn;

		let filter = db::accounts
			::user_id.eq(user_id);

		db::accounts::table
			.filter(filter)
			.load::<Account>(conn)
			.map_err(|e| FieldError::from(e))
	}

	field account(&executor, id: i32) -> FieldResult<Account> {
		let ctx = &executor.context();
		let conn = &ctx.conn;
		let current_user = &ctx.user;

		// Authorise
		let can = actions::accounts::authorise::can_access(conn, id, current_user)?;

		if can == false {
			return Err(FieldError::from("Unauthorized"))
		};

		Account::find(conn, id)
			.map_err(|e| FieldError::from(e))
	}

});
