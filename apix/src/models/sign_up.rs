#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct SignUp {
	pub name: String,
	pub username: String,
	pub email: String,
	pub password: String,
}
