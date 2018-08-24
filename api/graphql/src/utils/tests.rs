// use chrono::NaiveDate;
use db;
use diesel::pg::PgConnection;
use diesel::result::Error;
use diesel::Connection;
// use models::bookings::{Booking, BookingAttrs};
// use models::client::{Client, ClientAttrs};
// use models::room_bookings::{RoomBooking, RoomBookingAttrs};
// use models::rooms::{Room, RoomAttrs};
// use models::venues::{Venue, VenueAttrs};

pub fn with_db<F>(f: F) -> ()
where
	F: Fn(&PgConnection) -> (),
{
	let conn = db::get_test_connection();

	conn.test_transaction::<_, Error, _>(|| {
		f(&conn);
		Ok(())
	});
}

// Client
// pub fn client() -> ClientAttrs {
//     ClientAttrs {
//         name: "Client".to_string(),
//     }
// }

// impl ClientAttrs {
//     pub fn name(mut self, name: &str) -> ClientAttrs {
//         self.name = name.to_string();
//         self
//     }

//     pub fn save(self, conn: &PgConnection) -> Client {
//         Client::add(conn, self).unwrap()
//     }
// }

// Venue
// pub fn venue(client: &Client) -> VenueAttrs {
//     VenueAttrs {
//         client_id: client.id,
//         name: "Venue".to_owned(),
//         timezone: "Australia/Sydney".to_owned(),
//     }
// }

// impl VenueAttrs {
//     pub fn save(self, conn: &PgConnection) -> Venue {
//         Venue::add(conn, self).unwrap()
//     }
// }

// Room
// pub fn room(venue: &Venue) -> RoomAttrs {
//     RoomAttrs {
//         venue_id: venue.id,
//         name: "Room".to_owned(),
//     }
// }

// impl RoomAttrs {
//     pub fn save(self, conn: &PgConnection) -> Room {
//         Room::add(conn, self).unwrap()
//     }
// }

// Booking
// pub fn booking(venue: &Venue) -> BookingAttrs {
//     BookingAttrs {
//         venue_id: venue.id,
//         customer_name: "Sam".to_string(),
//     }
// }

// impl BookingAttrs {
//     pub fn save(self, conn: &PgConnection) -> Booking {
//         Booking::add(conn, self).unwrap()
//     }
// }

// Room Booking
// pub fn room_booking(room: &Room, booking: &Booking) -> RoomBookingAttrs {
//     RoomBookingAttrs {
//         room_id: room.id,
//         booking_id: booking.id,
//         first: NaiveDate::from_ymd(2017, 1, 1),
//         last: NaiveDate::from_ymd(2017, 1, 5),
//     }
// }

// impl RoomBookingAttrs {
//     pub fn first(mut self, first: NaiveDate) -> RoomBookingAttrs {
//         self.first = first;
//         self
//     }

//     pub fn last(mut self, last: NaiveDate) -> RoomBookingAttrs {
//         self.last = last;
//         self
//     }

//     pub fn save(self, conn: &PgConnection) -> RoomBooking {
//         RoomBooking::add(conn, self).unwrap()
//     }
// }
