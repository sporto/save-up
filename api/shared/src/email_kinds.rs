#[derive(Debug, PartialEq, Serialize, Deserialize)]
pub enum EmailKind {
	ConfirmEmail {
		email: String,
		confirmation_token: String,
	},
	Invite {
		inviter: String,
		email: String,
		invitation_token: String,
	},
}
