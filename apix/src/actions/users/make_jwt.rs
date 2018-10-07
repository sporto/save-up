use jwt::{encode, Header};
use serde_json;

use chrono::prelude::*;
use chrono::Duration;
use failure::Error;
use models::user::{TokenClaims, User};
use utils::config;

pub fn call(user: User) -> Result<String, Error> {
	let config = config::get()?;
	let secret = config.api_secret;

	let header = &Header::default();

	let exp = Utc::now() + Duration::weeks(52);

	let data = TokenClaims {
		user_id: user.id,
		email: user.email,
		username: user.username,
		name: user.name,
		role: user.role,
		exp: exp.timestamp(),
	};

	let json = serde_json::to_value(&data)?;

	encode(header, &json, secret.as_ref()).map_err(|e| format_err!("{}", e))
}
