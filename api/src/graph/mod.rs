use diesel::r2d2;
use juniper::{Context as JuniperContext, RootNode};
use models::user::User;
use utils::db_conn::ManagedPgConn;

pub mod app;
pub mod public;

pub struct AppContext {
	pub conn: r2d2::PooledConnection<ManagedPgConn>,
	pub user: User,
}

impl JuniperContext for AppContext {}

pub struct PublicContext {
	pub conn: r2d2::PooledConnection<ManagedPgConn>,
}

impl JuniperContext for PublicContext {}

pub type AppSchema =
	RootNode<'static, app::query_root::AppQueryRoot, app::mutation_root::AppMutationRoot>;

pub type PublicSchema = RootNode<
	'static,
	public::query_root::PublicQueryRoot,
	public::mutation_root::PublicMutationRoot,
>;

pub fn create_app_schema() -> AppSchema {
	let query_root = app::query_root::AppQueryRoot {};
	let mutation_root = app::mutation_root::AppMutationRoot {};
	AppSchema::new(query_root, mutation_root)
}

pub fn create_public_schema() -> PublicSchema {
	let query_root = public::query_root::PublicQueryRoot {};
	let mutation_root = public::mutation_root::PublicMutationRoot {};
	PublicSchema::new(query_root, mutation_root)
}
