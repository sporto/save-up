use juniper::FieldResult;

use graph_pub::context::{PublicContext};
use graph_pub::mutations;
use models::sign_in::SignIn;
use models::sign_up::SignUp;

pub struct PublicMutationRoot;

graphql_object!(PublicMutationRoot: PublicContext | &self | {

	field signUp(&executor, sign_up: SignUp) -> FieldResult<mutations::sign_up::SignUpResponse> {
		mutations::sign_up::call(executor, sign_up)
	}

	field signIn(&executor, sign_in: SignIn) -> FieldResult<mutations::sign_in::SignInResponse> {
		mutations::sign_in::call(executor, sign_in)
	}

	field confirm_email(
		&executor,
		input: mutations::confirm_email::ConfirmEmailInput
		) -> FieldResult<mutations::confirm_email::ConfirmEmailResponse> {
		
		mutations
			::confirm_email
			::call(executor, input)
	}

	field redeem_invitation(
		&executor,
		input: mutations::redeem_invitation::RedeemInvitationInput
	) -> FieldResult<mutations::redeem_invitation::RedeemInvitationResponse> {

		mutations
			::redeem_invitation
			::call(executor, input)
	}

	field request_password_reset(&executor, input: mutations::request_password_reset::RequestPasswordResetInput) -> FieldResult<mutations::request_password_reset::ResetPasswordResetResponse> {

		mutations
			::request_password_reset
			::call(executor, input)
	}

});
