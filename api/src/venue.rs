use chrono::NaiveDate;
use graph::query_root::Context;
use juniper::{FieldError, FieldResult};
use models::room_types::*;
use models::rooms::*;
use models::venues::*;
use services;

graphql_object!(Venue: Context |&self| {
	field id() -> i32 {
		self.id
	}

	field name() -> &str {
		self.name.as_str()
	}

	field timezone() -> &str {
		self.timezone.as_str()
	}

	field room_types(&executor) -> FieldResult<Vec<RoomType>> {
		let context = executor.context();
		let conn = context.pool.get().unwrap();

		RoomType
			::for_venue(&conn, self)
			.map_err(|e| FieldError::from(e) )
	}

	field rooms(&executor) -> FieldResult<Vec<Room>> {
		let context = executor.context();
		let conn = context.pool.get().unwrap();

		Room
			::for_venue(&conn, self)
			.map_err(|e| FieldError::from(e) )
	}

	field available_rooms(&executor, first: NaiveDate, last: NaiveDate) -> FieldResult<Vec<Room>> {
		let context = executor.context();
		let conn = context.pool.get().unwrap();

		let rooms = services::rooms::get_available
			::call(&conn, self.id, first, last);

		Ok(rooms)
	}
});
