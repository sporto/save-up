
use super::schema::invitations;
use chrono::{NaiveDateTime};
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
}
