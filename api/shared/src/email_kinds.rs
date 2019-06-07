#[derive(Debug, PartialEq, Serialize, Deserialize)]
pub enum EmailKind {
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
	ApproveTransactionRequest {
		email: String,
		amount_in_cents: i64,
	},
	ConfirmEmail {
		email: String,
		confirmation_url: String,
	},
	Invite {
		email: String,
		inviter_name: String,
		invitation_url: String,
	},
	RequestWithdrawal {
		email: String,
		name: String,
		amount_in_cents: i64,
	},
	RejectTransactionRequest {
		email: String,
		amount_in_cents: i64,
	},
	ResetPassword {
		email: String,
		reset_url: String,
	},
	Test {
		email: String,
	},
}
