table! {
    clients (id) {
        id -> Int4,
        name -> Varchar,
    }
}

table! {
    users (id) {
        id -> Int4,
        client_id -> Int4,
        role -> Varchar,
        name -> Varchar,
        email -> Varchar,
        encrypted_password -> Varchar,
        timezone -> Varchar,
    }
}

joinable!(users -> clients (client_id));
