use std::env;

#[derive(Debug)]
pub enum AppEnv {
    Test,
    Dev,
}

pub struct Config {
    pub database_url: String,
}

pub fn app_env() -> AppEnv {
    let environment: String = env::var("APP_ENV")
        .unwrap_or("dev".to_string());

    match environment.as_ref() {
        "test" =>
            AppEnv::Test,
        _ =>
            AppEnv::Dev,
    }
}

pub fn get() -> Config {
   let database_env_var =  match app_env() {
        AppEnv::Dev => "DATABASE_URL",
        AppEnv::Test => "DATABASE_URL_TEST",
    };

    let database_url = env::var(database_env_var)
        .expect("DATABASE_URL must be set");

    Config {
        database_url: database_url
    }
}
