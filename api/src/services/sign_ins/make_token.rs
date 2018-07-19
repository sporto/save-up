use frank_jwt::{self, Algorithm, encode, decode};

use models::users::{User};

pub fn call(user: User) -> Result<String, frank_jwt::Error> {
    let secret = "secret123".to_string();

    let mut header = json!({});

    let mut payload = json!({
        "userId" : "1",
        "email" : "sam@sample.com",
        "name" : "Sam",
    });

    encode(header, &secret, &payload, Algorithm::HS256)
}
