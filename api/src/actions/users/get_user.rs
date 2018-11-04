use actions;
use diesel::prelude::*;
use failure;
use models::user::{self, User};
use utils;

pub fn call(conn: &PgConnection, token: &str) -> Result<User, failure::Error> {
	let config = utils::config::get()?;

	if token == config.system_jwt {
		let user = user::system_user();
		return Ok(user);
	};

	let token_data = actions::users::decode_token::call(&token)?;

	user::User::find(conn, token_data.user_id)
		.map_err(|diesel_error| format_err!("{}", diesel_error))
}
