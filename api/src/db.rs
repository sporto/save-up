use diesel::pg::PgConnection;
use diesel::Connection;
use failure::Error;
use utils::config;

pub type Conn = PgConnection;

pub fn establish_connection() -> Result<PgConnection, Error> {
	let config = config::get()?;

	PgConnection::establish(&config.database_url)
		.map_err(|_| format_err!("Error connecting to {}", config.database_url))
}

#[cfg(test)]
use diesel::prelude::*;

#[cfg(test)]
pub fn get_test_connection() -> PgConnection {
	let app_env = config::app_env();

	match app_env {
		config::AppEnv::Test => {
			establish_connection().expect("Error getting connection")
		}
		_ => panic!("Not running in test"),
	}
}
