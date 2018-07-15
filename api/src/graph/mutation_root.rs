use graph::query_root::Context;
use juniper::{FieldError, FieldResult};
use validator::{ValidationError, ValidationErrors};

use models::errors::UpdateResult;
use services;

pub struct MutationRoot;

#[derive(GraphQLObject, Clone)]
struct MutationError {
    key: String,
    messages: Vec<String>,
}

fn to_mutation_errors(errors: ValidationErrors) -> Vec<MutationError> {
    errors
        .inner()
        .iter()
        .map(|(k, v)| MutationError {
            key: k.to_string(),
            messages: to_mutation_error_messages(v.to_vec()),
        })
        .collect()
}

fn to_mutation_error_messages(errors: Vec<ValidationError>) -> Vec<String> {
    errors
        .iter()
        .map(|e| {
            e.clone()
                .message
                .unwrap_or(::std::borrow::Cow::Borrowed("Invalid"))
                .to_string()
        })
        .collect()
}

graphql_object!(MutationRoot: Context | &self | {});
