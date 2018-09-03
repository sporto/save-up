#[derive(Debug, PartialEq, Serialize, Deserialize)]
pub enum EmailKind {
	ConfirmEmail {
		email: String,
		confirmation_token: String,
	},
	Invite {
		email: String,
		inviter_name: String,
		invitation_token: String,
	},
	RequestWithdrawal {
		email: String,
		name: String,
		amount_in_cents: i64,
	},
	ApproveTransactionRequest {
		email: String,
		amount_in_cents: i64,
	},
	RejectTransactionRequest {
		email: String,
		amount_in_cents: i64,
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
