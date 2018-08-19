use failure::Error;
use std::env;

#[derive(Debug)]
pub enum AppEnv {
	Test,
	Dev,
}

pub struct Config {
	// pub client_host: String,
	pub api_secret: String,
	pub database_url: String,
	pub system_jwt: String,
}

pub fn app_env() -> AppEnv {
	let environment: String = env::var("APP_ENV").unwrap_or("dev".to_string());

	match environment.as_ref() {
		"test" => AppEnv::Test,
		_ => AppEnv::Dev,
	}
}

pub fn get() -> Result<Config, Error> {
	// let database_env_var = match app_env() {
	// 	AppEnv::Dev => "DATABASE_URL",
	// 	AppEnv::Test => "DATABASE_URL_TEST",
	// };

	// let client_host = env::var("CLIENT_HOST")?;
	let api_secret = env::var("API_SECRET")
		.map_err(|_| format_err!("API_SECRET not found"))?;

	let db_name = env::var("DATABASE_NAME")?;
	let db_end_point = env::var("DATABASE_END_POINT")?;
	let db_user = env::var("DATABASE_USER")?;
	let db_pass = env::var("DATABASE_PASS")?;

	// e.g. postgres://user:password@host:3333/db_name
	let database_url =
		format!("postgres://{}:{}@{}/{}", db_user, db_pass, db_end_point, db_name);

	let system_jwt = env::var("SYSTEM_JWT")
		.map_err(|_| format_err!("SYSTEM_JWT not found"))?;

	let config = Config {
		// client_host: client_host,
		api_secret: api_secret,
		database_url: database_url,
		system_jwt: system_jwt,
	};

	Ok(config)
}
