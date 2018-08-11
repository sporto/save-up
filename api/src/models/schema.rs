table! {
    clients (id) {
        id -> Int4,
        created_at -> Timestamp,
        name -> Varchar,
    }
}

table! {
    users (id) {
        id -> Int4,
        created_at -> Timestamp,
        client_id -> Int4,
        email -> Varchar,
        password_hash -> Varchar,
        name -> Varchar,
        role -> Varchar,
        email_confirmation_token -> Nullable<Varchar>,
        email_confirmed_at -> Nullable<Timestamp>,
    }
}

joinable!(users -> clients (client_id));
