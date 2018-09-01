use diesel::pg::PgConnection;
use diesel::result::Error;
use utils::db_conn;
use diesel::Connection;
use models;

pub fn with_db<F>(f: F) -> ()
where
	F: Fn(&PgConnection) -> (),
{
	let conn = db_conn::get_test_connection();

	conn.test_transaction::<_, Error, _>(|| {
		f(&conn);
		Ok(())
	});
}

pub fn with_db_cleaner<F>(f: F) -> ()
where
	F: Fn(&PgConnection) -> (),
{
	let conn = db_conn::get_test_connection();

	f(&conn);

	models::client::Client::delete_all(&conn).unwrap();
	models::user::User::delete_all(&conn).unwrap();
	models::account::Account::delete_all(&conn).unwrap();
	models::transaction::Transaction::delete_all(&conn).unwrap();

	()
}
