#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use]
extern crate askama;
#[macro_use]
extern crate diesel;
extern crate diesel_migrations;
#[macro_use]
extern crate failure;
#[macro_use]
extern crate juniper;
#[macro_use]
extern crate serde_derive;
extern crate serde_json;
#[macro_use]
extern crate validator_derive;
#[macro_use]
extern crate lazy_static;
#[macro_use]
extern crate rocket;

extern crate bigdecimal;
extern crate chrono;
extern crate chrono_tz;
extern crate env_logger;
extern crate futures;
extern crate jsonwebtoken as jwt;
extern crate libreauth;
extern crate num_cpus;
extern crate r2d2;
extern crate range_check;
extern crate regex;
extern crate rocket_cors;
extern crate rusoto_core;
extern crate rusoto_ses;
extern crate serde;
extern crate url;
extern crate uuid;
extern crate validator;

#[get("/")]
fn index() -> &'static str {
	"Hello, world!"
}

fn main() {
	rocket::ignite().mount("/", routes![index]).launch();
}
