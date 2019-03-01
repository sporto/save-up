use crate::utils::config;
use failure::Error;

pub fn reset_url(token: &str) -> Result<String, Error> {
	let config = config::get()?;

	let url = format!("{}/password-resets/{}", config.client_host, token);

	Ok(url)
}

pub fn invitation_url(token: &str) -> Result<String, Error> {
	let config = config::get()?;

	let url = format!("{}/invitations/{}", config.client_host, token);

	Ok(url)
}

pub fn email_confirmation_url(token: &str) -> Result<String, Error> {
	let config = config::get()?;

	let url = format!("{}/email-confirmations/{}", config.client_host, token);

	Ok(url)
}
