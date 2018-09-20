use juniper::FieldResult;

use graph_app::context::AppContext;
use graph_app::mutations;

pub struct AppMutationRoot;

graphql_object!(AppMutationRoot: AppContext | &self | {

	field createUser(&executor, input: mutations::create_user::CreateUserInput) ->
	FieldResult<mutations::create_user::CreateUserResonse> {
		mutations::create_user::call(executor, input)
	}

	field invite(&executor, input: mutations::invite::InvitationInput) -> FieldResult<mutations::invite::InvitationResponse> {
		mutations::invite::call(executor, input)
	}

	field requestWithdraw(&executor, input: mutations::request_withdrawal::RequestWithdrawalInput) -> FieldResult<mutations::request_withdrawal::RequestWithdrawalResponse> {
		mutations::request_withdrawal::call(executor, input)
	}

	field resolveTransactionRequest(&executor, input: mutations::resolve_transaction_request::ResolveTransactionRequestInput) -> FieldResult<mutations::resolve_transaction_request::ResolveTransactionRequestResponse> {
		mutations::resolve_transaction_request::call(executor, input)
	}

	field deposit(&executor, input: mutations::deposit::DepositInput) -> FieldResult<mutations::deposit::DepositResponse> {
		mutations::deposit::call(executor, input)
	}

	field withdraw(&executor, input: mutations::withdraw::WithdrawalInput) -> FieldResult<mutations::withdraw::WithdrawalResponse> {
		mutations::withdraw::call(executor, input)
	}

});
