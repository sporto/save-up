use db;
// use std::collections::HashMap;
use rocket::http::{Cookie, Cookies};
use rocket::request::{self, FromRequest, Request};
use rocket::response::{Redirect, Flash};
use rocket_contrib::{Json};
use rocket::outcome::IntoOutcome;
use services;
use models::users::{self,User};
// use utils::config;

impl<'a, 'r> FromRequest<'a, 'r> for User {
    type Error = ();

    fn from_request(request: &'a Request<'r>) -> request::Outcome<User,()> {
        request.cookies()
            // .get_private("user_id")
            .get("user_id")
            .and_then(|cookie| cookie.value().parse().ok())
            .map(|id| 
                // TODO find the users in the DB
                User {
                    id: id,
                    client_id: 1,
                    role: "Jaom".to_owned(),
                    name: "Sam".to_owned(),
                    email: "Sam".to_owned(),
                    password_hash: "Sam".to_owned(),
                    timezone: "Sam".to_owned(),
                }
            )
            .or_forward(())
    }
}

#[post("/sign-up", format = "application/json", data = "<sign_up>")]
fn sign_up(
    conn: db::Conn,
    sign_up: Json<services::sign_ups::create::SignUp>,
) -> Json<SignInResponse> {

    let response = services::sign_ups::create::call(&conn, sign_up.0)
        .map(|user| {
            services::sign_ins::make_token::call(user)
                .map(|token|
                    SignInResponse {
                        error: None,
                        token: Some(token),
                    }
                ).unwrap_or(SignInResponse {
                    error: Some("Unable to create JWT Token".to_owned()),
                    token: None,
                })
        }).unwrap_or_else(|e|
            SignInResponse {
                error: Some(e.to_owned()),
                token: None,
            }
        );

    Json(response)
}

#[derive(Deserialize)]
struct SignIn {
    email: String,
    password: String,
}

#[derive(Serialize)]
struct SignInResponse {
    error: Option<String>,
    token: Option<String>,
}

#[post("/sign-in", format = "application/json", data = "<sign_in>")]
fn sign_in(sign_in: Json<SignIn>) -> Json<SignInResponse> {
    // TODO get actual user
    let response = if sign_in.0.email == "sam@sample.com" && sign_in.0.password == "password" {

        let user = users::newUser();

        services::sign_ins::make_token::call(user)
            .map(|token|
                SignInResponse {
                    error: None,
                    token: Some(token),
                }
            ).unwrap_or(SignInResponse {
                error: Some("Unable to create JWT Token".to_owned()),
                token: None,
            })

    } else {
        SignInResponse {
            error: Some("Invalid email or password.".to_owned()),
            token: None,
        }
    };

    Json(response)
}
