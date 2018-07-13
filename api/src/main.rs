extern crate actix_web;
use actix_web::{http, server, App, Path, Responder, HttpRequest};

fn index(req: HttpRequest) -> impl Responder {
    format!("Hello")
}

fn main() {
    server::new(
        || App::new()
            .route("/", http::Method::GET, index))
        .bind("127.0.0.1:8080").unwrap()
        .run();
}