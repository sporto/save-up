#![feature(plugin)]
#![plugin(rocket_codegen)]
#![feature(custom_derive)]

extern crate frank_jwt;
extern crate rocket;
extern crate rocket_contrib;
extern crate validator;
extern crate bcrypt;

// #[cfg(test)] #[macro_use] extern crate hamcrest;
#[macro_use]
extern crate diesel;
// #[macro_use] extern crate serde_derive;
#[macro_use]
extern crate juniper;
#[macro_use]
extern crate juniper_codegen;
extern crate juniper_rocket;
#[macro_use]
extern crate serde_derive;
#[macro_use] 
extern crate serde_json;
#[macro_use]
extern crate validator_derive;

extern crate hashids;

extern crate r2d2;
extern crate r2d2_diesel;
extern crate rocket_cors;

extern crate chrono;
extern crate chrono_tz;

mod db;
mod graph;
mod handlers;
mod models;
mod services;
mod utils;
// #[cfg(test)] mod test;

// use handlers;
use juniper::RootNode;
use rocket_cors::{AllowedHeaders, AllowedOrigins};
use rocket::http::Method;
use rocket::response::content;
use rocket::response::NamedFile;
use rocket::Rocket;
use rocket::State;
use std::path::{Path, PathBuf};
use utils::config;

type Schema = RootNode<'static, graph::query_root::QueryRoot, graph::mutation_root::MutationRoot>;

#[get("/assets/<file..>")]
fn assets(file: PathBuf) -> Option<NamedFile> {
    NamedFile::open(Path::new("assets/").join(file)).ok()
}

#[get("/seed")]
fn seed(conn: db::Conn) -> Option<()> {
    match services::seed_db::run(conn) {
        true => Some(()),
        false => None,
    }
}

#[get("/priv")]
fn graphiql() -> content::Html<String> {
    juniper_rocket::graphiql_source("/priv/graphql")
}

#[get("/priv/graphql?<request>")]
fn get_graphql_handler(
    context: State<graph::query_root::Context>,
    request: juniper_rocket::GraphQLRequest,
    schema: State<Schema>,
) -> juniper_rocket::GraphQLResponse {
    request.execute(&schema, &context)
}

#[post("/priv/graphql", data = "<request>")]
fn post_graphql_handler(
    context: State<graph::query_root::Context>,
    request: juniper_rocket::GraphQLRequest,
    schema: State<Schema>,
) -> juniper_rocket::GraphQLResponse {
    request.execute(&schema, &context)
}

fn rocket() -> Rocket {
    let config = config::get();
    let pool = db::init_pool();
    let query_root = graph::query_root::QueryRoot {};
    let mutation_root = graph::mutation_root::MutationRoot {};

    // CORS
    let (allowed_origins, failed_origins) =
        AllowedOrigins::some(&[&config.client_host]);

    assert!(failed_origins.is_empty());

    let allowed_methods = vec![Method::Get, Method::Post]
        .into_iter()
        .map(From::from)
        .collect();

    let allowed_headers = AllowedHeaders::some(&["Authorization", "Accept", "content-type"]);

    let options = rocket_cors::Cors {
        allowed_origins: allowed_origins,
        allowed_methods: allowed_methods,
        allowed_headers: allowed_headers,
        allow_credentials: true,
        ..Default::default()
    };

    let routes = routes![
        handlers::sign_up,
        handlers::sign_in,
        seed,
        graphiql,
        get_graphql_handler,
        post_graphql_handler,
        assets
    ];

    // let admin_routes = routes![
    //     handlers::admins,
    //     handlers::admins_empty,
    // ];

    rocket::ignite()
        .manage(pool.clone())
        .manage(graph::query_root::Context { pool: pool })
        .manage(Schema::new(query_root, mutation_root))
        .mount("/", routes)
        // .mount("/admins/", admin_routes)
        .attach(options)
}

fn main() {
    rocket().launch();
}
