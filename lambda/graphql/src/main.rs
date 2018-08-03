#[macro_use]
extern crate failure;
#[macro_use]
extern crate juniper;
#[macro_use]
extern crate serde_derive;

extern crate aws_lambda as lambda;
extern crate serde;
extern crate serde_json;

use juniper::{EmptyMutation, FieldResult, Variables};
use lambda::event::apigw::ApiGatewayProxyRequest;
use failure::Error;

#[derive(Serialize)]
struct Response {
    body: String,
}

#[derive(GraphQLObject)]
struct Client {
    id: String,
    name: String,
}

struct Context {
    // Use your real database pool here.
    // pool: DatabasePool,
}

impl juniper::Context for Context {}

struct Query;

graphql_object!(Query: Context |&self| {

    field apiVersion() -> &str {
        "1.0"
    }

    // Arguments to resolvers can either be simple types or input objects.
    // The executor is a special (optional) argument that allows accessing the context.
    field client(&executor, id: String) -> FieldResult<Client> {
        // Get the context from the executor.
        let context = executor.context();
        // Get a db connection.
        // let connection = context.pool.get_connection()?;
        // Execute a db query.
        // Note the use of `?` to propagate errors.
        // let human = connection.find_human(&id)?;
        // Return the result.
        Ok(Client{
            id: "1".to_owned(),
            name: "Client".to_owned(),
        })
    }
});

// struct Mutation;

// graphql_object!(Mutation: Context |&self| {

// field createHuman(&executor, new_human: NewHuman) -> FieldResult<Human> {
//     let db = executor.context().pool.get_connection()?;
//     let human: Human = db.insert_human(&new_human)?;
//     Ok(human)
// }
// });

type Schema = juniper::RootNode<'static, Query, EmptyMutation<Context>>;

fn main() {
    lambda::start(|request: ApiGatewayProxyRequest| {
        let ctx = Context {};

        let schema = &Schema::new(Query, EmptyMutation::new());

        request.body.ok_or(format_err!("No body")).and_then(|b| {
            let juniper_result = juniper::execute(&b, None, &schema, &Variables::new(), &ctx);

            juniper_result
                .map_err(|_| format_err!("Failed to execture query"))
                .and_then(|res| {
                    serde_json::to_string(&res)
                    .map_err(|_| format_err!("Failed to serialize response"))
                    .map(|serializedBody| Response {
                        body: serializedBody,
                    })
                })
        })
    })

}
