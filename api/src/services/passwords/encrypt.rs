use libreauth::pass::HashBuilder;

pub fn call(password: &str) -> Result<String, String> {
	let hasher = HashBuilder::new().finalize()
		.map_err(|_| "Failed to create hasher".to_owned())?;

	hasher.hash(&password.to_owned())
		.map_err(|_| "Failed to encrypt password".to_owned())
}
