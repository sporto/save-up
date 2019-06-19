use failure::Error;
use std::env;

#[derive(Debug, Clone, PartialEq)]
pub enum AppEnv {
	Test,
	Dev,
}

#[derive(Clone)]
pub struct Config {
	pub env:            AppEnv,
	pub api_port:       u16,
	pub api_secret:     String,
	pub aws_sns_email_topic_arn:   String,
	pub client_host:    String,
	pub database_url:   String,
	pub observer_email: String,
	pub system_jwt:     String,
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
		AppEnv::Dev => {
			VariableNames {
				database_url: "DATABASE_URL".into(),
			}
		},
		AppEnv::Test => {
			VariableNames {
				database_url: "DATABASE_URL_TEST".into(),
			}
		},
	}
}

pub fn get() -> Result<Config, Error> {
	let env = app_env();

	let names = variable_names();

	let api_port = env::var("API_PORT")
		.map_err(|_| format_err!("API_PORT not found"))
		.and_then(|p| 
			p.parse().map_err(|e| format_err!("{}", e))
		)?;

	let api_secret = env::var("API_SECRET")
		.map_err(|_| format_err!("API_SECRET not found"))?;

	let aws_sns_email_topic_arn = env::var("AWS_SNS_EMAIL_TOPIC_ARN")
		.map_err(|_| format_err!("AWS_SNS_EMAIL_TOPIC_ARN not found"))?;

	let client_host = env::var("CLIENT_HOST").map_err(|_| format_err!("CLIENT_HOST not found"))?;

	let database_url =
		env::var(names.database_url).map_err(|_| format_err!("database_url not found"))?;

	let observer_email =
		env::var("OBSERVER_EMAIL").map_err(|_| format_err!("OBSERVER_EMAIL not found"))?;

	let system_jwt = env::var("SYSTEM_JWT").map_err(|_| format_err!("SYSTEM_JWT not found"))?;

	let config = Config {
		env,
		api_port,
		api_secret,
		aws_sns_email_topic_arn,
		client_host,
		database_url,
		observer_email,
		system_jwt,
	};

	Ok(config)
}
