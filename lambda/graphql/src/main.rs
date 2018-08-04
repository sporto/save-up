#[macro_use]
extern crate diesel;
#[macro_use]
extern crate failure;
#[macro_use]
extern crate juniper;
#[macro_use]
extern crate serde_derive;
#[macro_use]
extern crate serde_json;
#[macro_use]
extern crate validator_derive;

extern crate aws_lambda as lambda;
extern crate bcrypt;
extern crate chrono;
extern crate chrono_tz;
extern crate frank_jwt;
extern crate serde;
extern crate validator;

use failure::Error;
use juniper::RootNode;
use juniper::{EmptyMutation, FieldResult, Variables};
use lambda::event::apigw::ApiGatewayProxyRequest;
use utils::config;

mod db;
mod graph;
mod models;
mod services;
mod utils;

#[derive(Serialize)]
struct Response {
    body: String,
    status: u16,
}

type Schema = RootNode<'static, graph::query_root::QueryRoot, graph::mutation_root::MutationRoot>;

fn main() {
    lambda::start(|request: ApiGatewayProxyRequest| {
        run(request).map(|value| Response {
            body: value,
            status: 200,
        })
    })
}

fn run(request: ApiGatewayProxyRequest) -> Result<String, Error> {
    let conn = db::establish_connection()?;

    let context = graph::query_root::Context { conn: conn };

    let query_root = graph::query_root::QueryRoot {};

    let mutation_root = graph::mutation_root::MutationRoot {};

    let schema = Schema::new(query_root, mutation_root);

    let body = request.body.ok_or(format_err!("Body not found"))?;

    let juniper_result = juniper::execute(&body, None, &schema, &Variables::new(), &context)
        .map_err(|e| format_err!("Failed to execute query"))?;

    serde_json::to_string(&juniper_result).map_err(|_| format_err!("Failed to serialize response"))
}
