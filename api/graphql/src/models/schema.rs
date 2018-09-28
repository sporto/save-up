table! {
    accounts (id) {
        id -> Int4,
        created_at -> Timestamp,
        user_id -> Int4,
        name -> Varchar,
        yearly_interest -> Numeric,
        kind -> Varchar,
        state -> Varchar,
    }
}

table! {
    clients (id) {
        id -> Int4,
        created_at -> Timestamp,
        name -> Varchar,
    }
}

table! {
    invitations (id) {
        id -> Int4,
        created_at -> Timestamp,
        user_id -> Int4,
        email -> Varchar,
        role -> Varchar,
        token -> Varchar,
        used_at -> Nullable<Timestamp>,
    }
}

table! {
    transaction_requests (id) {
        id -> Int4,
        created_at -> Timestamp,
        account_id -> Int4,
        kind -> Varchar,
        amount -> Money,
        state -> Varchar,
    }
}

table! {
    transactions (id) {
        id -> Int4,
        created_at -> Timestamp,
        account_id -> Int4,
        kind -> Varchar,
        amount -> Money,
        balance -> Money,
    }
}

table! {
    users (id) {
        id -> Int4,
        created_at -> Timestamp,
        client_id -> Int4,
        email -> Nullable<Varchar>,
        password_hash -> Varchar,
        name -> Varchar,
        role -> Varchar,
        email_confirmation_token -> Nullable<Varchar>,
        email_confirmed_at -> Nullable<Timestamp>,
        username -> Varchar,
        archived_at -> Nullable<Timestamp>,
        password_reset_token -> Nullable<Varchar>,
    }
}

joinable!(users -> clients (client_id));
joinable!(invitations -> users (user_id));
joinable!(accounts -> users (user_id));
joinable!(transactions -> accounts (account_id));
joinable!(transaction_requests -> accounts (account_id));
