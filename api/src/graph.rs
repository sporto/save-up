use actix::prelude::*;
use actix_web::{
	error, http, middleware, server, App, AsyncResponder, Error, FutureResponse, HttpRequest,
	HttpResponse, Json, State,
};
use app;
use diesel::prelude::*;
use diesel::r2d2;
use juniper::http::GraphQLRequest;
use juniper::Context as JuniperContext;
use juniper::FieldResult;
use juniper::RootNode;
use models;
use models::user::User;
use public;
use serde_json;
use std;
use utils::db_conn::DBPool;

pub struct AppContext {
	pub conn: r2d2::PooledConnection<r2d2::ConnectionManager<PgConnection>>,
	pub user: User,
}

impl JuniperContext for AppContext {}

pub struct PublicContext {
	pub conn: r2d2::PooledConnection<r2d2::ConnectionManager<PgConnection>>,
}

impl JuniperContext for PublicContext {}

#[derive(Serialize, Deserialize)]
pub struct GraphQLData(GraphQLRequest);

// Setup graphql result type
impl Message for GraphQLData {
	type Result = Result<String, Error>;
}

pub struct GraphQLAppExecutor {
	pub schema: std::sync::Arc<AppSchema>,
	pub db_pool: DBPool,
}

pub struct GraphQLPublicExecutor {
	pub schema: std::sync::Arc<PublicSchema>,
	pub db_pool: DBPool,
}

impl Actor for GraphQLAppExecutor {
	type Context = SyncContext<Self>;
}

impl Actor for GraphQLPublicExecutor {
	type Context = SyncContext<Self>;
}

impl Handler<GraphQLData> for GraphQLAppExecutor {
	type Result = Result<String, Error>;

	fn handle(&mut self, msg: GraphQLData, _: &mut Self::Context) -> Self::Result {
		let conn = self.db_pool.get().map_err(|e| error::ErrorBadRequest(e))?;

		let user = models::user::system_user(); // TODO Get real user

		let context = AppContext {
			conn: conn,
			user: user,
		};

		let res = msg.0.execute(&self.schema, &context);
		let res_text = serde_json::to_string(&res)?;

		Ok(res_text)
	}
}

impl Handler<GraphQLData> for GraphQLPublicExecutor {
	type Result = Result<String, Error>;

	fn handle(&mut self, msg: GraphQLData, _: &mut Self::Context) -> Self::Result {
		let conn = self.db_pool.get().map_err(|e| error::ErrorBadRequest(e))?;

		let context = PublicContext { conn: conn };

		let res = msg.0.execute(&self.schema, &context);
		let res_text = serde_json::to_string(&res)?;

		Ok(res_text)
	}
}

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

pub fn create_app_executor(pool: DBPool) -> Addr<GraphQLAppExecutor> {
	SyncArbiter::start(3, move || GraphQLAppExecutor {
		schema: std::sync::Arc::new(create_app_schema()),
		db_pool: pool.clone(),
	})
}

pub fn create_public_executor(pool: DBPool) -> Addr<GraphQLPublicExecutor> {
	SyncArbiter::start(3, move || GraphQLPublicExecutor {
		schema: std::sync::Arc::new(create_public_schema()),
		db_pool: pool.clone(),
	})
}
