use rocket_contrib::Template;
use rocket::request::Form;

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

#[derive(FromForm)]
struct SignUpForm {
	name: String,
	email: String,
	password: String,
}


#[post("/sign_up", data = "<sign_up_form>")]
fn sign_up_create(sign_up_form: Form<SignUpForm>) -> String {
	format!("Ok")
}
