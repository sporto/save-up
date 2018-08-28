use juniper::FieldResult;

use graph_app::context::AppContext;
use graph_app::mutations;

pub struct AppMutationRoot;

graphql_object!(AppMutationRoot: AppContext | &self | {

	field invite(&executor, input: mutations::invite::InvitationInput) -> FieldResult<mutations::invite::InvitationResponse> {
		mutations::invite::call(executor, input)
	}

	field deposit(&executor, input: mutations::deposit::DepositInput) -> FieldResult<mutations::deposit::DepositResponse> {
		mutations::deposit::call(executor, input)
	}

});
