use diesel::{prelude::*, r2d2};
use rocket::{
	http::Status,
	request::{self, FromRequest},
	Outcome, Request, State,
};
use std::ops::Deref;
use utils::config;

pub type ManagedPgConn = r2d2::ConnectionManager<PgConnection>;
pub type DBPool = r2d2::Pool<ManagedPgConn>;
pub type PooledConnection = r2d2::PooledConnection<ManagedPgConn>;

pub fn init_pool() -> DBPool {
	let config = config::get().expect("Failed to get config");

	let manager = r2d2::ConnectionManager::<PgConnection>::new(config.database_url);

	r2d2::Pool::new(manager).expect("Failed to create pool.")

	// r2d2::Pool::builder()
	// 	.build(manager)
	// 	.expect("Failed to create pool.")
}

/// Db Connection request guard type: wrapper around r2d2 pooled connection
pub struct DBConn(pub PooledConnection);

impl Deref for DBConn {
	type Target = PgConnection;

	#[inline(always)]
	fn deref(&self) -> &Self::Target {
		&self.0
	}
}

/// Attempts to retrieve a single connection from the managed database pool. If
/// no pool is currently managed, fails with an `InternalServerError` status. If
/// no connections are available, fails with a `ServiceUnavailable` status.
impl<'a, 'r> FromRequest<'a, 'r> for DBConn {
	type Error = ();

	fn from_request(request: &'a Request<'r>) -> request::Outcome<DBConn, ()> {
		let pool = request.guard::<State<DBPool>>()?;
		match pool.get() {
			Ok(conn) => Outcome::Success(DBConn(conn)),
			Err(_) => Outcome::Failure((Status::ServiceUnavailable, ())),
		}
	}
}

#[cfg(test)]
pub fn get_test_connection() -> PgConnection {
	let app_env = config::app_env();

	match app_env {
		config::AppEnv::Test => establish_connection().expect("Error getting connection"),
		_ => panic!("Not running in test"),
	}
}
