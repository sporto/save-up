
#[derive(Deserialize, Clone, GraphQLInputObject)]
pub struct SignUp {
	pub name: String,
	pub email: String,
	pub password: String,
	pub timezone: String,
}
