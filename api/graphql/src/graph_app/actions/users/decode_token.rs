use jwt::{decode, Validation};

use models::user::{TokenData};
use utils::config;
use failure::Error;

pub fn call(token: &str) -> Result<TokenData, Error> {
	let config = config::get()?;
	let secret = config.api_secret;

	decode::<TokenData>(&token, secret.as_ref(), &Validation::default())
		.map_err(|e| format_err!("{}", e))
		.map(|t| t.claims )
}
