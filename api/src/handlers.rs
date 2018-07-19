use db;
use std::collections::HashMap;
use rocket::http::{Cookie, Cookies};
use rocket::request::{self, FlashMessage, Form, FromRequest, Request};
use rocket::response::{Redirect, Flash};
use rocket_contrib::{Json,Template};
use rocket::outcome::IntoOutcome;
use services::sign_ups;
use models::users::User;
use utils::config;

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

#[derive(Serialize)]
struct RootView {
}

#[get("/")]
fn index() -> Template {
    let context = RootView {};

    Template::render("root", &context)
}

#[get("/test")]
fn test() -> Template {
    let configuration = config::get();
    let mut context = HashMap::new();

    context.insert("client_host", configuration.client_host);

    Template::render("test", &context)
}

#[derive(Serialize)]
struct SignUpView {
    error: String,
}

#[get("/sign_up")]
fn sign_up() -> Template {
    let context = SignUpView {
        error: "".to_string(),
    };

    Template::render("sign_up", &context)
}

#[post("/sign_up", data = "<sign_up_form>")]
fn sign_up_create(
    conn: db::Conn,
    mut cookies: Cookies,
    sign_up_form: Form<sign_ups::create::SignUp>,
) -> Result<Redirect, Template> {
    sign_ups::create::call(&conn, sign_up_form.get().clone())
        .map(|user| {
            // cookies.add_private(
            cookies.add(
                Cookie::new("user_id", user.id.to_string())
            );
            Redirect::to("/admins")
        })
        .map_err(|e| {
            let context = SignUpView {
                error: e.to_string(),
            };

            Template::render("sign_up", &context)
        })
}

#[derive(Deserialize)]
struct SignIn {
    email: String,
    password: String
}

#[derive(Serialize)]
struct SignInResponse {
    error: Option<String>,
    token: Option<String>,
}

#[post("/sign-in", format = "application/json", data = "<sign_in>")]
fn sign_in(sign_in: Json<SignIn>) -> Json<SignInResponse> {
    if sign_in.0.email == "sam@sample.com" && sign_in.0.password == "password" {
        Json(SignInResponse {
            error: None,
            token: Some("abc".to_owned()),
        })
    } else {
        Json(SignInResponse {
            error: Some("Invalid email or password.".to_owned()),
            token: None,
        })
    }
}

#[post("/sign_out")]
fn sign_out(mut cookies: Cookies) -> Flash<Redirect> {
    cookies.remove_private(Cookie::named("user_id"));

    // Redirect::to(uri!(sign_in)),

    Flash::success(
        Redirect::to("/"),
        "Successfully logged out.",
    )
}

// Admins

#[get("/")]
fn admins(user: User) -> Template {
    let mut context = HashMap::new();

    context.insert("user_email", user.email);

    Template::render("admins/root", &context)
}

#[get("/", rank = 2)]
fn admins_empty() -> Redirect {
    Redirect::to("/sign_in")
}
