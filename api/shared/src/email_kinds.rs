#[derive(Debug, PartialEq, Serialize, Deserialize)]
pub enum EmailKind {
	ConfirmEmail {
		email: String,
		confirmation_token: String,
	},
	Invite {
		email: String,
		inviter: String,
		invitation_token: String,
	},
	AcknowledgeDeposit {
		email: String,
		amount_in_cents: i64,
		balance_in_cents: i64,
	},
	AcknowledgeWithdrawal {
		email: String,
		amount_in_cents: i64,
		balance_in_cents: i64,
	},
}
