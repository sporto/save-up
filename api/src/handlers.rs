use rocket_contrib::Template;

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
