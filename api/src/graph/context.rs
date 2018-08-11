use diesel::pg::PgConnection;
use juniper::{Context as JuniperContext};
use models::users::User;

pub struct Context {
	pub conn: PgConnection,
	pub user: Option<User>,
}

impl JuniperContext for Context {}
