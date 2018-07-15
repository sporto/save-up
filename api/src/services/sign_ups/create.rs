use diesel::dsl::exists;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::select;
use bcrypt::{DEFAULT_COST, hash};
use models::clients::{Client, ClientAttrs};
// use models::errors::UpdateResult;
// use models::schema::clients;
use models::users::{User, UserAttrs};
// use rocket::request::Form;
use models::schema::users;
use validator::Validate;
// use utils::tests::with_db;

#[derive(FromForm, Clone)]
pub struct SignUp {
    pub name: String,
    pub email: String,
    pub password: String,
    pub timezone: String,
}

pub fn call(conn: &PgConnection, sign_up: SignUp) -> Result<User, String> {
    // Validate the user attrs
    let temp_user_attrs = UserAttrs {
        client_id: 1,
        role: "parent".to_string(),
        name: sign_up.name.clone(),
        email: sign_up.email.clone(),
        password_hash: "abc".to_owned(),
        timezone: sign_up.timezone.clone(),
    };

    temp_user_attrs.validate().map_err(|e| e.to_string())?;

    // Check if we have a user with this email already
    let filter = users::table.filter(users::email.eq(sign_up.email.clone()));

    let existing = select(exists(filter)).get_result(conn);

    match existing {
        Ok(true) => Err("Already taken".to_owned()),

        Ok(false) => {
            let client_attrs = ClientAttrs {
                name: sign_up.name.clone(),
            };

            let password_hash = hash(&sign_up.password, DEFAULT_COST).map_err(|e| e.to_string())?;

            // Create client and then user
            Client::create(conn, client_attrs)
                .and_then(|client| {
                    let user_attrs = UserAttrs {
                        client_id: client.id,
                        role: "parent".to_string(),
                        name: sign_up.name,
                        email: sign_up.email,
                        password_hash: password_hash,
                        timezone: sign_up.timezone,
                    };

                    User::create(conn, user_attrs)
                })
                .map_err(|e| e.to_string())
        }
        Err(e) => Err(e.to_string()),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use utils::tests;

    #[test]
    fn it_creates_a_client_and_user() {
        tests::with_db(|conn| {
            let attrs = SignUp {
                name: "Sam".to_string(),
                email: "sam@sample.com".to_string(),
                password: "password".to_string(),
                timezone: "TZ".to_string(),
            };

            let result = call(conn, attrs);

            assert!(result.is_ok());

            let user = result.unwrap();
            // println!("{:?}", user.password_hash);

            assert_eq!(user.name, "Sam".to_owned());
            assert_eq!(user.email, "sam@sample.com".to_owned());
            assert_eq!(user.role, "parent".to_owned());
            assert_ne!(user.password_hash, "password".to_owned());
        })
    }

    #[test]
    fn it_fails_with_invalid_email() {
        tests::with_db(|conn| {
            let attrs = SignUp {
                name: "Sam".to_string(),
                email: "flamingo".to_string(),
                password: "password".to_string(),
                timezone: "TZ".to_string(),
            };

            let result = call(conn, attrs);

            assert!(result.is_err());
        })
    }
}
