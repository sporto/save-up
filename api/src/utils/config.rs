use failure::Error;
use std::env;

#[derive(Debug)]
pub enum AppEnv {
	Test,
	Dev,
}

#[derive(Clone)]
pub struct Config {
	pub api_secret: String,
	pub client_host: String,
	pub database_url: String,
	pub system_jwt: String,
}

struct VariableNames {
	database_url: String,
}

pub fn app_env() -> AppEnv {
	let environment: String = env::var("APP_ENV").unwrap_or("dev".to_string());

	match environment.as_ref() {
		"test" => AppEnv::Test,
		_ => AppEnv::Dev,
	}
}

fn variable_names() -> VariableNames {
	match app_env() {
		AppEnv::Dev => VariableNames {
			database_url: "DATABASE_URL".into(),
		},
		AppEnv::Test => VariableNames {
			database_url: "DATABASE_URL_TEST".into(),
		},
	}
}

pub fn get() -> Result<Config, Error> {
	let names = variable_names();

	let api_secret = env::var("API_SECRET").map_err(|_| format_err!("API_SECRET not found"))?;

	let client_host = env::var("CLIENT_HOST").map_err(|_| format_err!("CLIENT_HOST not found"))?;

	let database_url =
		env::var(names.database_url).map_err(|_| format_err!("database_url not found"))?;

	let system_jwt = env::var("SYSTEM_JWT").map_err(|_| format_err!("SYSTEM_JWT not found"))?;

	let config = Config {
		api_secret: api_secret,
		client_host: client_host,
		database_url: database_url,
		system_jwt: system_jwt,
	};

	Ok(config)
}
