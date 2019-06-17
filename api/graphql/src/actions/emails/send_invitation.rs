use failure::Error;

use crate::{
	actions::emails::send,
	models::{ invitation::Invitation, user::User},
	utils::links,
};
use shared::emails::{Email, EmailKind};


pub fn call(current_user: &User, invitation: &Invitation) -> Result<(), Error> {
	let email_address = &invitation.email.clone();

	let token = &invitation.token.clone();

	let invitation_url = links::invitation_url(&token)?;

	let email_kind = EmailKind::Invite {
		inviter_name:   current_user.name.clone(),
		invitation_url: invitation_url.to_string(),
	};

	let email = Email {
		to: email_address.to_string(),
		kind: email_kind,
	};

	send::call(&email)
}
