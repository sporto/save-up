use crate::{
	actions,
	models::user::{self, User},
	utils,
};
use diesel::prelude::*;
use failure;

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
