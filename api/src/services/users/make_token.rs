use frank_jwt::{Algorithm, encode};
use serde_json;

use models::users::{User};
use utils::config;
use failure::Error;

#[derive(Serialize)]
pub struct TokenData {
	pub id: i32,
	pub email: String,
	pub name: String,
	pub role: String,
}

pub fn call(user: User) -> Result<String, Error> {
	let config = config::get()?;
	let secret = config.api_secret;

	let header = json!({});

	let data = TokenData {
		id : user.id,
		email : user.email,
		name : user.name,
		role : user.role,
	};

	let json = serde_json::to_value(&data)?;

	encode(header, &secret, &json, Algorithm::HS256)
		.map_err(|_| format_err!("Failed to encode token"))
}
