use juniper::FieldResult;

use graph_app::context::AppContext;
use graph_app::mutations;

pub struct AppMutationRoot;

graphql_object!(AppMutationRoot: AppContext | &self | {

	field invite(&executor, attrs: mutations::invite::InvitationInput) -> FieldResult<mutations::invite::InvitationResponse> {
		mutations::invite::call(executor, attrs)
	}

});
