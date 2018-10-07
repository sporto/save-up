use diesel::pg::PgConnection;
use juniper::Context as JuniperContext;
use models::user::User;

pub struct AppContext {
	pub conn: PgConnection,
	pub user: User,
}

impl JuniperContext for AppContext {}
