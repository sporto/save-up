use super::schema::invitations;
use crate::models::role::Role;
use chrono::NaiveDateTime;
use diesel::{self, pg::PgConnection, prelude::*, result::Error};
use validator::Validate;

#[derive(Queryable, GraphQLObject, Debug)]
pub struct Invitation {
	pub id:         i32,
	pub created_at: NaiveDateTime,
	pub user_id:    i32,
	pub email:      String,
	pub role:       Role,
	pub token:      String,
	pub used_at:    Option<NaiveDateTime>,
}

#[derive(Insertable, Validate)]
#[table_name = "invitations"]
pub struct InvitationAttrs {
	pub user_id: i32,
	#[validate(email(message="Email is not valid"))]
	pub email: String,
	pub role: Role,
	pub token: String,
	pub used_at: Option<NaiveDateTime>,
}

impl Invitation {
	#[allow(dead_code)]
	pub fn create(conn: &PgConnection, attrs: InvitationAttrs) -> Result<Invitation, Error> {
		diesel::insert_into(invitations::dsl::invitations)
			.values(&attrs)
			.get_results(conn)
			.and_then(|mut invitations| invitations.pop().ok_or(Error::NotFound))
	}

	#[allow(dead_code)]
	pub fn find_by_token(conn: &PgConnection, token: &str) -> Result<Invitation, Error> {
		invitations::table
			.filter(invitations::token.eq(token))
			.get_result(conn)
	}
}

#[cfg(test)]
pub mod factories {
	use super::*;
	use models::user::{Role, User};

	#[allow(dead_code)]
	pub fn invitation_attrs(inviter: &User) -> InvitationAttrs {
		InvitationAttrs {
			user_id: inviter.id,
			email:   "sam@sample.com".into(),
			role:    Role::Investor,
			token:   "abc".into(),
			used_at: None,
		}
	}

	impl InvitationAttrs {
		pub fn save(self, conn: &PgConnection) -> Invitation {
			Invitation::create(conn, self).unwrap()
		}

		pub fn token(mut self, token: &str) -> Self {
			self.token = token.to_owned();
			self
		}
	}
}
