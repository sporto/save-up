use libreauth::pass::HashBuilder;

pub fn call(password: &str, password_hash: &str) -> Result<bool, String> {
	let checker = HashBuilder::from_phc(password_hash.to_string())
		.map_err(|_| "Failed to create checker".to_owned())?;

	let is_valid = checker.is_valid(&password.to_owned());

	Ok(is_valid)
}
