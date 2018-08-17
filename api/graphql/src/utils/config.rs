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
	let database_env_var = match app_env() {
		AppEnv::Dev => "DATABASE_URL",
		AppEnv::Test => "DATABASE_URL_TEST",
	};

	// let client_host = env::var("CLIENT_HOST")?;
	let api_secret = env::var("API_SECRET")
		.map_err(|_| format_err!("API_SECRET not found"))?;

	let database_url = env::var(database_env_var)?;

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