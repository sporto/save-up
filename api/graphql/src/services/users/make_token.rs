use jwt::{encode, Header};
use serde_json;

use failure::Error;
use models::users::{TokenData, User};
use utils::config;

pub fn call(user: User) -> Result<String, Error> {
	let config = config::get()?;
	let secret = config.api_secret;

	let header = &Header::default();

	let data = TokenData {
		user_id: user.id,
		email: user.email,
		name: user.name,
		role: user.role,
	};

	let json = serde_json::to_value(&data)?;

	encode(header, &json, secret.as_ref()).map_err(|e| format_err!("{}", e))
}
