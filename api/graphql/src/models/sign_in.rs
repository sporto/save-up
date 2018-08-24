
#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct SignIn {
	pub email: String,
	pub password: String,
}
