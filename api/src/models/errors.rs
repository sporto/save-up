use diesel::result::Error;
use validator::ValidationErrors;

pub enum UpdateResult<T> {
	DbErr(Error),
	ValidationErr(ValidationErrors),
	Ok(T),
}

impl<T> UpdateResult<T> {
	pub fn is_ok(self) -> bool {
		match self {
			UpdateResult::Ok(_) => true,
			_ => false,
		}
	}

	pub fn unwrap(self) -> T {
		match self {
			UpdateResult::DbErr(error) => panic!("{:?}", error),
			UpdateResult::ValidationErr(errors) => panic!("{:?}", errors),
			UpdateResult::Ok(t) => t,
		}
	}
}
