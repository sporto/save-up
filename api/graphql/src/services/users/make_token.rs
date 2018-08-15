use jwt::{encode, Header};
use serde_json;

use models::users::{User, TokenData};
use utils::config;
use failure::Error;

pub fn call(user: User) -> Result<String, Error> {
	let config = config::get()?;
	let secret = config.api_secret;

	let header = &Header::default();

	let data = TokenData {
		user_id : user.id,
		email : user.email,
		name : user.name,
		role : user.role,
	};

	let json = serde_json::to_value(&data)?;

	encode(header, &json, secret.as_ref())
		.map_err(|_| format_err!("Failed to encode token"))
}
