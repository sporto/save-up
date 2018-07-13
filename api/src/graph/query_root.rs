use diesel::pg::PgConnection;
use juniper::{Context as JuniperContext, FieldError, FieldResult};
use r2d2;
use r2d2_diesel;

use chrono_tz::America;
use chrono_tz::Australia;

use models::clients::*;
use models::users::*;

pub struct Context {
	pub pool: r2d2::Pool<r2d2_diesel::ConnectionManager<PgConnection>>,
}

impl JuniperContext for Context {}

pub struct QueryRoot;

graphql_object!(QueryRoot: Context |&self| {

	field apiVersion() -> &str {
		"1.0"
	}

	field client(&executor) -> FieldResult<Client> {
		let context = executor.context();
		let conn = context.pool.get().unwrap();

		// TODO get current client
		Client::first(&conn)
			.map_err(|e| FieldError::from(e) )

		// Client::one(&conn, 1 as i32)
		//     .map_err(|e| FieldError::from(e) )
	}

	field users(&executor) -> FieldResult<Vec<User>> {
		let context = executor.context();
		let conn = context.pool.get().unwrap();
		let users = User::all(&conn);

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
