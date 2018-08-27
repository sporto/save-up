use super::schema::invitations;
use chrono::NaiveDateTime;
use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error;
use validator::Validate;

#[derive(Queryable, GraphQLObject, Debug)]
pub struct Invitation {
	pub id: i32,
	pub created_at: NaiveDateTime,
	pub user_id: i32,
	pub email: String,
	pub role: String,
	pub token: String,
	pub used_at: Option<NaiveDateTime>,
}

#[derive(Insertable, Validate)]
#[table_name = "invitations"]
pub struct InvitationAttrs {
	pub user_id: i32,
	#[validate(email)]
	pub email: String,
	pub role: String,
	pub token: String,
	pub used_at: Option<NaiveDateTime>,
}

impl Invitation {
	pub fn create(conn: &PgConnection, attrs: InvitationAttrs) -> Result<Invitation, Error> {
		diesel::insert_into(invitations::dsl::invitations)
			.values(&attrs)
			.get_results(conn)
			.and_then(|mut invitations| invitations.pop().ok_or(Error::NotFound))
	}

	pub fn find_by_token(conn: &PgConnection, token: &str) -> Result<Invitation, Error> {
		invitations::table
			.filter(invitations::token.eq(token))
			.get_result(conn)
	}
}

#[cfg(test)]
use models::user::{User, ROLE_INVESTOR};

#[cfg(test)]
pub fn invitation_attrs(inviter: &User) -> InvitationAttrs {
	InvitationAttrs {
		user_id: inviter.id,
		email: "sam@sample.com".into(),
		role: ROLE_INVESTOR.into(),
		token: "abc".into(),
		used_at: None,
	}
}

#[cfg(test)]
impl InvitationAttrs {
	pub fn save(self, conn: &PgConnection) -> Invitation {
		Invitation::create(conn, self).unwrap()
	}

	pub fn token(mut self, token: &str) -> Self {
		self.token = token.to_owned();
		self
	}
}
