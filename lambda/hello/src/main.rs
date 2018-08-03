#[macro_use]
extern crate juniper;
#[macro_use]
extern crate serde_derive;

extern crate aws_lambda as lambda;
extern crate serde;
extern crate serde_json;

use juniper::{FieldResult, Variables, EmptyMutation};
use lambda::event::apigw::ApiGatewayProxyRequest;

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
    let ctx = Context {};

    let schema = &Schema::new(Query, EmptyMutation::new());

    // let (res, _errors) = juniper::execute(
    //     "query { client { name } }",
    //     None,
    //     &schema,
    //     &Variables::new(),
    //     &ctx,
    // ).unwrap();

    // start the runtime, and return a greeting every time we are invoked
    lambda::start(|request: ApiGatewayProxyRequest| {
        Ok(Response {
            body: request.path.unwrap_or("N/A".to_owned()),
        })
    })

    // lambda::start(|()| {
    //     Ok(Response {
    //         body: "N/A".to_owned(),
    //     })
    // })
}
