#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct SignIn {
	pub username_or_email: String,
	pub password: String,
}
