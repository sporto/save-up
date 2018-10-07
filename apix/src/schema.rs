use app;
use juniper::FieldResult;
use juniper::RootNode;
use public;

#[derive(GraphQLEnum)]
enum Episode {
	NewHope,
	Empire,
	Jedi,
}

#[derive(GraphQLObject)]
#[graphql(description = "A humanoid creature in the Star Wars universe")]
struct Human {
	id: String,
	name: String,
	appears_in: Vec<Episode>,
	home_planet: String,
}

#[derive(GraphQLInputObject)]
#[graphql(description = "A humanoid creature in the Star Wars universe")]
struct NewHuman {
	name: String,
	appears_in: Vec<Episode>,
	home_planet: String,
}

pub struct QueryRoot;

graphql_object!(QueryRoot: () |&self| {
    field human(&executor, id: String) -> FieldResult<Human> {
        Ok(Human{
            id: "1234".to_owned(),
            name: "Luke".to_owned(),
            appears_in: vec![Episode::NewHope],
            home_planet: "Mars".to_owned(),
        })
    }
});

pub struct MutationRoot;

graphql_object!(MutationRoot: () |&self| {
    field createHuman(&executor, new_human: NewHuman) -> FieldResult<Human> {
        Ok(Human{
            id: "1234".to_owned(),
            name: new_human.name,
            appears_in: new_human.appears_in,
            home_planet: new_human.home_planet,
        })
    }
});

pub type Schema = RootNode<'static, QueryRoot, MutationRoot>;

pub fn create_schema() -> Schema {
	Schema::new(QueryRoot {}, MutationRoot {})
}

type PublicSchema = RootNode<
	'static,
	public::query_root::PublicQueryRoot,
	public::mutation_root::PublicMutationRoot,
>;

pub fn create_public_schema() -> PublicSchema {
	let query_root = public::query_root::PublicQueryRoot {};
	let mutation_root = public::mutation_root::PublicMutationRoot {};
	PublicSchema::new(query_root, mutation_root)
}

type AppSchema =
	RootNode<'static, app::query_root::AppQueryRoot, app::mutation_root::AppMutationRoot>;

pub fn create_app_schema() -> AppSchema {
	let query_root = app::query_root::AppQueryRoot {};
	let mutation_root = app::mutation_root::AppMutationRoot {};
	AppSchema::new(query_root, mutation_root)
}
