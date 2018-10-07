use actions;
use bigdecimal::BigDecimal;
use bigdecimal::FromPrimitive;
use graph::AppContext;
use juniper::{Executor, FieldError, FieldResult};
use models::account::Account;
use utils::mutations::failure_to_mutation_errors;
use utils::mutations::MutationError;

#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct ChangeAccountInterestInput {
	pub account_id: i32,
	pub yearly_interest: f64,
}

#[derive(Clone)]
pub struct ChangeAccountInterestResponse {
	success: bool,
	errors: Vec<MutationError>,
	account: Option<Account>,
}

graphql_object!(ChangeAccountInterestResponse: AppContext |&self| {
	field success() -> bool {
		self.success
	}

	field errors() -> &Vec<MutationError> {
		&self.errors
	}

	field account() -> &Option<Account> {
		&self.account
	}
});

pub fn call(
	executor: &Executor<AppContext>,
	input: ChangeAccountInterestInput,
) -> FieldResult<ChangeAccountInterestResponse> {
	let context = executor.context();
	let conn = &context.conn;
	let current_user = &context.user;

	// Authorise
	let can =
		actions::accounts::authorise::can_admin(&conn, input.account_id.clone(), &current_user)?;

	if can == false {
		return Err(FieldError::from("Unauthorised"));
	}

	let yearly_interest = BigDecimal::from_f64(input.yearly_interest)
		.ok_or(format_err!("Failed to convert yearly_interest"))?;

	let result = actions::accounts::change_interest::call(&conn, input.account_id, yearly_interest);

	let response = match result {
		Ok(account) => ChangeAccountInterestResponse {
			success: true,
			errors: vec![],
			account: Some(account),
		},
		Err(e) => ChangeAccountInterestResponse {
			success: false,
			errors: failure_to_mutation_errors(e),
			account: None,
		},
	};

	Ok(response)
}
