use jwt::{decode, Validation};

use models::user::{TokenClaims};
use utils::config;
use failure::Error;

pub fn call(token: &str) -> Result<TokenClaims, Error> {
	let config = config::get()?;
	let secret = config.api_secret;
	let validation = Validation::default();

	decode::<TokenClaims>(&token, secret.as_ref(), &validation)
		.map_err(|e| format_err!("{}", e))
		.map(|t| t.claims )
}
