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
extern crate jsonwebtoken as jwt;
extern crate serde;
extern crate uuid;
extern crate validator;

use lambda::event::apigw::{ApiGatewayProxyRequest};

use std::collections::HashMap;

mod db;
mod models;
mod services;
mod utils;

fn main() {
	lambda::start(|request: ApiGatewayProxyRequest| {
		Ok("FO")
	})
}
