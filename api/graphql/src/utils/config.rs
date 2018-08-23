use failure::Error;
use std::env;
use url::Url;

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

struct VariableNames {
	database_name: String,
	database_end_point: String,
	database_user: String,
	database_pass: String,
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
			database_name: "DATABASE_NAME".into(),
			database_end_point: "DATABASE_END_POINT".into(),
			database_user: "DATABASE_USER".into(),
			database_pass: "DATABASE_PASS".into(),
		},
		AppEnv::Test => VariableNames {
			database_name: "DATABASE_NAME_TEST".into(),
			database_end_point: "DATABASE_END_POINT_TEST".into(),
			database_user: "DATABASE_USER_TEST".into(),
			database_pass: "DATABASE_PASS_TEST".into(),
		}
	}
}

pub fn get() -> Result<Config, Error> {
	let names = variable_names();

	// let client_host = env::var("CLIENT_HOST")?;
	let api_secret = env::var("API_SECRET")
		.map_err(|_| format_err!("API_SECRET not found"))?;

	let db_name = env::var(names.database_name)
		.map_err(|_| format_err!("database_name not found"))?;

	let db_end_point = env::var(names.database_end_point)
			.map_err(|_| format_err!("database_end_point not found"))?;

	let db_user = env::var(names.database_user)
			.map_err(|_| format_err!("database_user not found"))?;

	let db_pass = env::var(names.database_pass)
			.map_err(|_| format_err!("database_pass not found"))?;

	let mut url = Url::parse("postgres://user@host/name")?;

	url.set_username(&db_user);
	url.set_host(Some(&db_end_point));
	url.set_path(&db_name);

	if db_pass != "" {
		url.set_password(Some(&db_pass));
	}

	// e.g. postgres://user:password@host:3333/db_name
	// let database_url =
	// 	format!("postgres://{}:{}@{}/{}", db_user, db_pass, db_end_point, db_name);

	let database_url =
		url.to_string();

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
