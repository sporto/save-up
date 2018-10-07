// use utils::db_conn;
// use models::client::{Client, ClientAttrs};
// use models::user::{User, UserAttrs};
use diesel::pg::PgConnection;
use utils::config;

#[allow(dead_code)]
pub fn run(conn: PgConnection) -> bool {
	let app_env = config::app_env();

	match app_env {
		config::AppEnv::Test => {
			println!("Seeding");
			let _ = seed(conn);
			true
		}
		_ => {
			println!("Cannot seed in {:?}", app_env);
			false
		}
	}
}

#[allow(dead_code)]
fn seed(_conn: PgConnection) -> Result<String, String> {
	// let _ = User::delete_all(&conn);
	// let _ = Client::delete_all(&conn);

	// let client_attrs = ClientAttrs {};

	// Client::create(&conn, client_attrs)
	// 	.map_err(|e| format!("{:?}", e))
	// 	.map(|client| {
	// 		let user_attrs = UserAttrs {
	// 			client_id: client.id,
	// 			name: "Sam Sample".to_string(),
	// 			email: "sam@sample.com".to_string(),
	// 			timezone: "Australia/Melbourne".to_string(),
	// 		};

	// 		let _ = User::add(&conn, user_attrs);

	// 		"Ok".to_string()
	// 	})

	Err("Not implemented".to_string())
}
