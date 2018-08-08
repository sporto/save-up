use diesel::pg::PgConnection;
use juniper::{Context as JuniperContext, FieldError, FieldResult};

use chrono_tz::America;
use chrono_tz::Australia;

use models::clients::*;
use models::users::*;

pub struct Context {
	pub conn: PgConnection,
}

impl JuniperContext for Context {}

pub struct QueryRoot;

graphql_object!(QueryRoot: Context |&self| {

	field apiVersion() -> &str {
		"1.0"
	}

	field client(&executor) -> FieldResult<Client> {
		let context = executor.context();

		// TODO get current client
		Client::first(&context.conn)
			.map_err(|e| FieldError::from(e) )

		// Client::one(&conn, 1 as i32)
		//     .map_err(|e| FieldError::from(e) )
	}

	field users(&executor) -> FieldResult<Vec<User>> {
		let context = executor.context();

		let users = User::all(&context.conn);

		Ok(users)
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
