// use juniper::{FieldError, FieldResult};

// use chrono_tz::America;
// use chrono_tz::Australia;

use crate::graph::PublicContext;

pub struct PublicQueryRoot;

graphql_object!(PublicQueryRoot: PublicContext |&self| {
	field apiVersion() -> &str {
		"1.0"
	}
});
