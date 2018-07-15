use db;
use rocket::request::Form;
use rocket::response::Redirect;
use rocket_contrib::Template;
use services::sign_ups;

#[get("/")]
fn index() -> String {
    format!("Hello")
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
    sign_up_form: Form<sign_ups::create::SignUp>,
) -> Result<Redirect, Template> {
    sign_ups::create::call(&conn, sign_up_form.get().clone())
        .map(|_user| Redirect::to("/home"))
        .map_err(|e| {
            let context = SignUpView {
                error: e.to_string(),
            };

            Template::render("sign_up", &context)
        })

    // format!("Ok")
}
