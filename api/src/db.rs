use diesel::pg::PgConnection;
use diesel::Connection;
use utils::config;
use failure::Error;

pub type Conn = PgConnection;

pub fn establish_connection() -> Result<PgConnection, Error> {
    let config = config::get()?;
    
    PgConnection::establish(&config.database_url)
        .map_err(|_| format_err!(
                "Error connecting to {}", config.database_url
            ))
}

// #[cfg(test)]
// use diesel::prelude::*;

// #[cfg(test)]
// pub fn get_test_connection() -> PgConnection {
//     let app_env = config::app_env();
//     let configuration = config::get();

//     match app_env {
//         config::AppEnv::Test => {
//             let database_url = configuration.database_url;

//             PgConnection::establish(&database_url)
//                 .expect(&format!("Error connecting to {}", database_url))
//         }
//         _ => panic!("Not running in test"),
//     }
// }
