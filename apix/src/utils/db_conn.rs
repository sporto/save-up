use diesel::pg::PgConnection;
use diesel::Connection;
use failure::Error;
use r2d2;
use r2d2_diesel::ConnectionManager;
use utils::config;

pub type Pool = r2d2::Pool<ConnectionManager<PgConnection>>;

pub fn init_pool() -> Pool {
	let config = config::get().unwrap();

	let manager = ConnectionManager::<PgConnection>::new(config.database_url);

	r2d2::Pool::builder()
		.build(manager)
		.expect("Failed to create pool.")
}

pub fn establish_connection() -> Result<PgConnection, Error> {
	let config = config::get()?;

	PgConnection::establish(&config.database_url)
		.map_err(|_| format_err!("Error connecting to {}", config.database_url))
}

#[cfg(test)]
pub fn get_test_connection() -> PgConnection {
	let app_env = config::app_env();

	match app_env {
		config::AppEnv::Test => establish_connection().expect("Error getting connection"),
		_ => panic!("Not running in test"),
	}
}
