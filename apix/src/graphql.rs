use actix::prelude::*;
use actix_web::{
	error, http, middleware, server, App, AsyncResponder, Error, FutureResponse, HttpRequest,
	HttpResponse, Json, State,
};
use app;
use juniper::http::GraphQLRequest;
use juniper::FieldResult;
use juniper::RootNode;
use models;
use public;
use serde_json;
use std;
use utils::db_conn::DBPool;

#[derive(Serialize, Deserialize)]
pub struct GraphQLData(GraphQLRequest);

// Setup graphql result type
impl Message for GraphQLData {
	type Result = Result<String, Error>;
}

// #[derive(GraphQLEnum)]
// enum Episode {
// 	NewHope,
// 	Empire,
// 	Jedi,
// }

// #[derive(GraphQLObject)]
// #[graphql(description = "A humanoid creature in the Star Wars universe")]
// struct Human {
// 	id: String,
// 	name: String,
// 	appears_in: Vec<Episode>,
// 	home_planet: String,
// }

// #[derive(GraphQLInputObject)]
// #[graphql(description = "A humanoid creature in the Star Wars universe")]
// struct NewHuman {
// 	name: String,
// 	appears_in: Vec<Episode>,
// 	home_planet: String,
// }

// pub struct QueryRoot;

// graphql_object!(QueryRoot: () |&self| {
//     field human(&executor, id: String) -> FieldResult<Human> {
//         Ok(Human{
//             id: "1234".to_owned(),
//             name: "Luke".to_owned(),
//             appears_in: vec![Episode::NewHope],
//             home_planet: "Mars".to_owned(),
//         })
//     }
// });

// pub struct MutationRoot;

// graphql_object!(MutationRoot: () |&self| {
//     field createHuman(&executor, new_human: NewHuman) -> FieldResult<Human> {
//         Ok(Human{
//             id: "1234".to_owned(),
//             name: new_human.name,
//             appears_in: new_human.appears_in,
//             home_planet: new_human.home_planet,
//         })
//     }
// });

// pub type Schema = RootNode<'static, QueryRoot, MutationRoot>;

// pub fn create_schema() -> Schema {
// 	Schema::new(QueryRoot {}, MutationRoot {})
// }

// Public

// pub struct GraphQLPublicExecutor {
// 	schema: std::sync::Arc<PublicSchema>,
// }

// impl GraphQLPublicExecutor {
// 	fn new(schema: std::sync::Arc<PublicSchema>) -> GraphQLPublicExecutor {
// 		GraphQLPublicExecutor { schema: schema }
// 	}
// }

// impl Actor for GraphQLPublicExecutor {
// 	type Context = SyncContext<Self>;
// }

// pub type PublicSchema = RootNode<
// 	'static,
// 	public::query_root::PublicQueryRoot,
// 	public::mutation_root::PublicMutationRoot,
// >;

// pub fn create_public_schema() -> PublicSchema {
// 	let query_root = public::query_root::PublicQueryRoot {};
// 	let mutation_root = public::mutation_root::PublicMutationRoot {};
// 	PublicSchema::new(query_root, mutation_root)
// }

// App

pub struct GraphQLAppExecutor {
	pub schema: std::sync::Arc<AppSchema>,
	pub db_pool: DBPool,
}

impl Actor for GraphQLAppExecutor {
	type Context = SyncContext<Self>;
}

impl Handler<GraphQLData> for GraphQLAppExecutor {
	type Result = Result<String, Error>;

	fn handle(&mut self, msg: GraphQLData, _: &mut Self::Context) -> Self::Result {
		let conn = self.db_pool.get().map_err(|e| error::ErrorBadRequest(e))?;

		let user = models::user::system_user(); // TODO Get real user

		let context = app::context::AppContext {
			conn: conn,
			user: user,
		};

		let res = msg.0.execute(&self.schema, &context);
		let res_text = serde_json::to_string(&res)?;

		Ok(res_text)
	}
}

// impl GraphQLAppExecutor {
// 	fn new(schema: std::sync::Arc<graphql::AppSchema>) -> GraphQLAppExecutor {
// 		GraphQLAppExecutor { schema: schema }
// 	}
// }

pub type AppSchema =
	RootNode<'static, app::query_root::AppQueryRoot, app::mutation_root::AppMutationRoot>;

pub fn create_app_schema() -> AppSchema {
	let query_root = app::query_root::AppQueryRoot {};
	let mutation_root = app::mutation_root::AppMutationRoot {};
	AppSchema::new(query_root, mutation_root)
}

pub fn create_app_executor(pool: DBPool) -> Addr<GraphQLAppExecutor> {
	SyncArbiter::start(3, move || GraphQLAppExecutor {
		schema: std::sync::Arc::new(create_app_schema()),
		db_pool: pool.clone(),
	})
}
