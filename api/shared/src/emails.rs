#[derive(Debug, PartialEq, Serialize, Deserialize)]
pub struct Email {
	pub to: String,
	pub kind: EmailKind,
}

#[derive(Debug, PartialEq, Serialize, Deserialize)]
pub enum EmailKind {
	AcknowledgeDeposit {
		amount_in_cents: i64,
		balance_in_cents: i64,
	},
	AcknowledgeWithdrawal {
		amount_in_cents: i64,
		balance_in_cents: i64,
	},
	ApproveTransactionRequest {
		amount_in_cents: i64,
	},
	ConfirmEmail {
		confirmation_url: String,
	},
	Invite {
		inviter_name: String,
		invitation_url: String,
	},
	RequestWithdrawal {
		name: String,
		amount_in_cents: i64,
	},
	RejectTransactionRequest {
		amount_in_cents: i64,
	},
	ResetPassword {
		reset_url: String,
	},
	Test {
	},
}
