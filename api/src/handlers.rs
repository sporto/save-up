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
struct TemplateContext {
    name: String,
}

#[get("/sign_up")]
fn sign_up() -> Template {
    let context = TemplateContext {
        name: "Hello".to_string(),
    };

    Template::render("sign_up", &context)
}

#[post("/sign_up", data = "<sign_up_form>")]
fn sign_up_create(conn: db::Conn, sign_up_form: Form<sign_ups::create::SignUp>) -> Result<Redirect, Template> {
    sign_ups::create::call(&conn, sign_up_form.get().clone())
        .map( |user|
            Redirect::to("/home")
        ).map_err(|_e| {
            let context = TemplateContext {
                name: "Hello".to_string(),
            };

            Template::render("sign_up", &context)
        })

    // format!("Ok")
}
