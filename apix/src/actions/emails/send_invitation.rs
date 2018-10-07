use failure::Error;

use actions::emails::send;
use models::email_kinds::EmailKind;
use models::invitation::Invitation;
use models::user::User;
use utils::links;

pub fn call(current_user: &User, invitation: &Invitation) -> Result<(), Error> {
	let invitee_email = &invitation.email.clone();

	let token = &invitation.token.clone();

	let invitation_url = links::invitation_url(&token)?;

	let email_kind = EmailKind::Invite {
		email: invitee_email.to_string(),
		inviter_name: current_user.name.clone(),
		invitation_url: invitation_url.to_string(),
	};

	send::call(&email_kind)
}
