use juniper::FieldResult;

use graph_app::context::AppContext;
use graph_app::mutations;
use graph_app::mutations::archive_user::{self, ArchiveUserResponse};
use graph_app::mutations::change_interest::{
	self, ChangeAccountInterestInput, ChangeAccountInterestResponse,
};
use graph_app::mutations::create_user::{self, CreateUserInput, CreateUserResponse};
use graph_app::mutations::deposit::{self, DepositInput, DepositResponse};
use graph_app::mutations::invite_admin::{self, InvitationInput, InvitationResponse};
use graph_app::mutations::request_withdrawal::{
	self, RequestWithdrawalInput, RequestWithdrawalResponse,
};
use graph_app::mutations::resolve_transaction_request::{
	self, ResolveTransactionRequestInput, ResolveTransactionRequestResponse,
};
use graph_app::mutations::unarchive_user::{self, UnarchiveUserResponse};
use graph_app::mutations::withdraw::{self, WithdrawalInput, WithdrawalResponse};

pub struct AppMutationRoot;

graphql_object!(AppMutationRoot: AppContext | &self | {

	// users
	field createUser(&executor, input: CreateUserInput) ->
	FieldResult<CreateUserResponse> {
		create_user::call(executor, input)
	}

	field archiveUser(&executor, user_id: i32) ->
	FieldResult<ArchiveUserResponse> {
		archive_user::call(executor, user_id)
	}

	field unarchiveUser(&executor, user_id: i32) ->
	FieldResult<UnarchiveUserResponse> {
		unarchive_user::call(executor, user_id)
	}

	field inviteAdmin(&executor, input: InvitationInput) -> FieldResult<InvitationResponse> {
		invite_admin::call(executor, input)
	}

	// accounts
	field changeAccountInterest(&executor, input: ChangeAccountInterestInput) -> FieldResult<ChangeAccountInterestResponse> {
		change_interest::call(executor, input)
	}

	// transactions
	field requestWithdraw(&executor, input: RequestWithdrawalInput) -> FieldResult<RequestWithdrawalResponse> {
		request_withdrawal::call(executor, input)
	}

	field resolveTransactionRequest(&executor, input: ResolveTransactionRequestInput) -> FieldResult<ResolveTransactionRequestResponse> {
		resolve_transaction_request::call(executor, input)
	}

	field deposit(&executor, input: DepositInput) -> FieldResult<DepositResponse> {
		deposit::call(executor, input)
	}

	field withdraw(&executor, input: WithdrawalInput) -> FieldResult<WithdrawalResponse> {
		withdraw::call(executor, input)
	}

});
