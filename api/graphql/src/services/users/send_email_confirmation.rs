use failure::Error;
use models::users::{User};

pub fn call(user: &User) -> Result<(), Error> {
	Ok(())
}
