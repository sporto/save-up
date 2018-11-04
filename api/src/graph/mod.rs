use actions;
use diesel::prelude::*;
use diesel::r2d2;
use failure;
use juniper::http::GraphQLRequest;
use juniper::Context as JuniperContext;
use juniper::RootNode;
use models;
use models::user::User;
use serde_json;
use std;
use utils;
use utils::db_conn::{DBPool, ManagedPgConn};

pub mod app;
pub mod public;

pub struct AppContext {
	pub pool: r2d2::Pool<ManagedPgConn>,
	pub user: User,
}

impl JuniperContext for AppContext {}

pub struct PublicContext {
	pub pool: r2d2::Pool<ManagedPgConn>,
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
