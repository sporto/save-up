use diesel::pg::PgConnection;
use juniper::{Context as JuniperContext};
use models::users::User;

pub struct PublicContext {
	pub conn: PgConnection,
}

pub struct Context {
	pub conn: PgConnection,
	pub user: Option<User>,
}

impl JuniperContext for PublicContext {}
impl JuniperContext for Context {}
