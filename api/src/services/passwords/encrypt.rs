use bcrypt::{hash, DEFAULT_COST};

pub fn call(password: &str) -> Result<String, String> {
	hash(&password, DEFAULT_COST)
		.map_err(|e| e.to_string())
}
