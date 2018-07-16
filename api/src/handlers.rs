use db;
use rocket::http::{Cookie, Cookies};
use rocket::request::Form;
use rocket::response::Redirect;
use rocket_contrib::Template;
use services::sign_ups;

#[derive(Serialize)]
struct RootView {
}

#[get("/")]
fn index() -> Template {
    let context = RootView {};

    Template::render("root", &context)
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
            cookies.add_private(Cookie::new("user_id", user.id.to_string()));
            Redirect::to("/admins/home")
        })
        .map_err(|e| {
            let context = SignUpView {
                error: e.to_string(),
            };

            Template::render("sign_up", &context)
        })
}

#[get("/admins/home")]
fn admins_home() -> Template {
    let context = SignUpView {
        error: "".to_string(),
    };

    Template::render("admins/home", &context)
}
