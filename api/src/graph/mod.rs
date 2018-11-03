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

// #[derive(Serialize, Deserialize)]
// pub struct ProcessAppGraphQlRequest {
// 	pub request: GraphQLRequest,
// 	pub token: String,
// }

// Setup graphql result type
// impl Message for ProcessPublicGraphQlRequest {
// 	type Result = Result<String, Error>;
// }

// impl Message for ProcessAppGraphQlRequest {
// 	type Result = Result<String, Error>;
// }

// pub struct GraphQLAppExecutor {
// 	pub schema: std::sync::Arc<AppSchema>,
// 	pub db_pool: DBPool,
// }

// 	fn handle(&mut self, msg: ProcessAppGraphQlRequest, _: &mut Self::Context) -> Self::Result {
// 		let conn = self.db_pool.get().map_err(|e| error::ErrorBadRequest(e))?;

// 		let user = get_user(&conn, &msg.token)?;

// 		let ctx = AppContext {
// 			conn: conn,
// 			user: user,
// 		};

// 		let res = msg.request.execute(&self.schema, &context);
// 		let res_text = serde_json::to_string(&res)?;

// 		Ok(res_text)
// 	}
// }

fn get_user(conn: &PgConnection, token: &str) -> Result<User, failure::Error> {
	let config = utils::config::get()?;

	if token == config.system_jwt {
		let user = models::user::system_user();
		return Ok(user);
	};

	let token_data = actions::users::decode_token::call(&token)?;

	models::user::User::find(conn, token_data.user_id)
		.map_err(|diesel_error| format_err!("{}", diesel_error))
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

// pub fn create_app_executor(capacity: usize, pool: DBPool) -> Addr<GraphQLAppExecutor> {
// 	SyncArbiter::start(capacity, move || GraphQLAppExecutor {
// 		schema: std::sync::Arc::new(create_app_schema()),
// 		db_pool: pool.clone(),
// 	})
// }

// pub fn create_public_executor(capacity: usize, pool: DBPool) -> Addr<GraphQLPublicExecutor> {
// 	SyncArbiter::start(capacity, move || GraphQLPublicExecutor {
// 		schema: std::sync::Arc::new(create_public_schema()),
// 		db_pool: pool.clone(),
// 	})
// }
