use failure::Error;

use graph_common::actions::emails::send;
use models::invitation::Invitation;
use models::user::User;
use shared::email_kinds::EmailKind;

pub fn call(current_user: &User, invitation: &Invitation) -> Result<(), Error> {
	let invitee_email = &invitation.email.clone();

	let invitation_token = &invitation.token.clone();

	let email_kind = EmailKind::Invite {
		email: invitee_email.to_string(),
		inviter_name: current_user.name.clone(),
		invitation_token: invitation_token.to_string(),
	};

	send::call(&email_kind)
}
