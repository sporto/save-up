use diesel::pg::PgConnection;
use juniper::Context as JuniperContext;

pub struct PublicContext {
	pub conn: PgConnection,
}

impl JuniperContext for PublicContext {}
