use diesel::dsl::exists;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::select;
use models::clients::{Client, ClientAttrs};
// use models::errors::UpdateResult;
// use models::schema::clients;
use models::users::{User, UserAttrs};
// use rocket::request::Form;
use models::schema::users;

#[derive(FromForm, Clone)]
pub struct SignUp {
    pub name: String,
    pub email: String,
    pub password: String,
    pub timezone: String,
}

pub fn call(conn: &PgConnection, sign_up: SignUp) -> Result<User, String> {
    let filter = users::table.filter(users::email.eq(sign_up.email.clone()));

    let existing = select(exists(filter)).get_result(conn);

    match existing {
        Ok(true) => Err("Already taken".to_owned()),

        Ok(false) => {
            let client_attrs = ClientAttrs {
                name: sign_up.name.clone(),
            };

            // Create client and then user
            Client::create(conn, client_attrs)
                .and_then(|client| {
                    let user_attrs = UserAttrs {
                        client_id: client.id,
                        role: "parent".to_string(),
                        name: sign_up.name,
                        email: sign_up.email,
                        encrypted_password: "ABC".to_string(),
                        timezone: sign_up.timezone,
                    };

                    User::create(conn, user_attrs)
                })
                .map_err(|e| e.to_string())
        }
        Err(e) => Err(e.to_string()),
    }
}
