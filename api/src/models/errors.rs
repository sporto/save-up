use diesel::result::Error;
use validator::ValidationErrors;

#[allow(dead_code)]
pub enum UpdateResult<T> {
    DbErr(Error),
    ValidationErr(ValidationErrors),
    Ok(T),
}

impl<T> UpdateResult<T> {
    #[allow(dead_code)]
    pub fn is_ok(self) -> bool {
        match self {
            UpdateResult::Ok(_) => true,
            _ => false,
        }
    }

    #[allow(dead_code)]
    pub fn unwrap(self) -> T {
        match self {
            UpdateResult::DbErr(error) => panic!("{:?}", error),
            UpdateResult::ValidationErr(errors) => panic!("{:?}", errors),
            UpdateResult::Ok(t) => t,
        }
    }
}
