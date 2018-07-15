use diesel::pg::PgConnection;
use r2d2;
use r2d2_diesel::ConnectionManager;
use rocket::http::Status;
use rocket::request::{self, FromRequest};
use rocket::{Outcome, Request, State};
use std::ops::Deref;
use utils::config;

pub type Pool = r2d2::Pool<ConnectionManager<PgConnection>>;

pub fn init_pool() -> Pool {
    let config = config::get();

    let manager = ConnectionManager::<PgConnection>::new(config.database_url);

    r2d2::Pool::builder()
        .build(manager)
        .expect("Failed to create pool.")
}

pub struct Conn(pub r2d2::PooledConnection<ConnectionManager<PgConnection>>);

impl Deref for Conn {
    type Target = PgConnection;

    #[inline(always)]
    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl<'a, 'r> FromRequest<'a, 'r> for Conn {
    type Error = ();

    fn from_request(request: &'a Request<'r>) -> request::Outcome<Conn, ()> {
        let pool = request.guard::<State<Pool>>()?;

        match pool.get() {
            Ok(conn) => Outcome::Success(Conn(conn)),
            Err(_) => Outcome::Failure((Status::ServiceUnavailable, ())),
        }
    }
}

// Testing setup

#[cfg(test)]
use diesel::prelude::*;

#[cfg(test)]
pub fn get_test_connection() -> PgConnection {
    let app_env = config::app_env();
    let configuration = config::get();

    match app_env {
        config::AppEnv::Test => {
            let database_url = configuration.database_url;

            PgConnection::establish(&database_url)
                .expect(&format!("Error connecting to {}", database_url))
        }
        _ => panic!("Not running in test"),
    }
}
