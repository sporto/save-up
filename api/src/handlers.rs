use rocket_contrib::Template;
use db;
use rocket::request::Form;
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
fn sign_up_create(conn: db::Conn, sign_up_form: Form<sign_ups::create::SignUp>) -> String {

	let res =
		sign_ups::create::call(
			&conn,
			sign_up_form.get().clone()
		);

	format!("Ok")
}
