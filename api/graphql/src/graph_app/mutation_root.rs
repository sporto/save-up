use failure::Error;
use juniper::FieldResult;
use validator::{ValidationError, ValidationErrors};

use graph_app::context::AppContext;
use graph_app::mutations;
use models::sign_in::SignIn;
use models::sign_up::SignUp;

pub struct AppMutationRoot;

graphql_object!(AppMutationRoot: AppContext | &self | {

	field invite(&executor, attrs: mutations::invite::InvitationInput) -> FieldResult<mutations::invite::InvitationResponse> {
		mutations::invite::call(executor, attrs)
	}

});
