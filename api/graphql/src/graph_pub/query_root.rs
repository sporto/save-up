use juniper::{FieldError, FieldResult};

use chrono_tz::America;
use chrono_tz::Australia;

use graph_pub::context::PublicContext;

pub struct PublicQueryRoot;

graphql_object!(PublicQueryRoot: PublicContext |&self| {
	field apiVersion() -> &str {
		"1.0"
	}
});
