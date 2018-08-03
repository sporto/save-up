#[macro_use]
extern crate serde_derive;

extern crate serde;
extern crate serde_json;
extern crate aws_lambda as lambda;

#[derive(Serialize)]
struct Response {
    body: String,
}

fn main() {
    // start the runtime, and return a greeting every time we are invoked
    lambda::start(|()| 
        Ok(Response {
            body: "Hello".to_owned(),
        })
    )
}
