// use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::r2d2;
use juniper::Context as JuniperContext;
use models::user::User;

pub struct AppContext {
	pub conn: r2d2::PooledConnection<r2d2::ConnectionManager<PgConnection>>,
	pub user: User,
}

impl JuniperContext for AppContext {}
