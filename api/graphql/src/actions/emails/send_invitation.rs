use failure::Error;

use crate::{
	actions::emails::send,
	models::{ invitation::Invitation, user::User},
	utils::links,
};
use shared::email_kinds::EmailKind;


pub fn call(current_user: &User, invitation: &Invitation) -> Result<(), Error> {
	let invitee_email = &invitation.email.clone();

	let token = &invitation.token.clone();

	let invitation_url = links::invitation_url(&token)?;

	let email_kind = EmailKind::Invite {
		email:          invitee_email.to_string(),
		inviter_name:   current_user.name.clone(),
		invitation_url: invitation_url.to_string(),
	};

	send::call(&email_kind)
}
