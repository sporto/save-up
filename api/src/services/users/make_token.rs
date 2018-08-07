use frank_jwt::{self, Algorithm, encode};

use models::users::{User};

pub fn call(user: User) -> Result<String, frank_jwt::Error> {
	let secret = "secret123".to_string();

	let header = json!({});

	let payload = json!({
		"userId" : user.id,
		"email" : user.email,
		"name" : user.name,
		"role" : user.role,
	});

	encode(header, &secret, &payload, Algorithm::HS256)
}
