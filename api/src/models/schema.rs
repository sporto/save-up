table! {
	bookings (id) {
		id -> Int4,
		venue_id -> Int4,
		customer_name -> Varchar,
	}
}

table! {
	clients (id) {
		id -> Int4,
		name -> Varchar,
	}
}

table! {
	room_bookings (id) {
		id -> Int4,
		room_id -> Int4,
		booking_id -> Int4,
		first -> Date,
		last -> Date,
	}
}

table! {
	room_types (id) {
		id -> Int4,
		venue_id -> Int4,
		name -> Varchar,
	}
}

table! {
	rooms (id) {
		id -> Int4,
		venue_id -> Int4,
		name -> Varchar,
	}
}

table! {
	users (id) {
		id -> Int4,
		client_id -> Int4,
		name -> Varchar,
		email -> Varchar,
		timezone -> Varchar,
	}
}

table! {
	venues (id) {
		id -> Int4,
		client_id -> Int4,
		name -> Varchar,
		timezone -> Varchar,
	}
}

joinable!(users -> clients (client_id));
joinable!(venues -> clients (client_id));
joinable!(room_types -> venues (venue_id));
joinable!(rooms -> venues (venue_id));
joinable!(bookings -> venues (venue_id));
joinable!(room_bookings -> rooms (room_id));
joinable!(room_bookings -> bookings (booking_id));
