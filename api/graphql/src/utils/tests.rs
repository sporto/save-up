use diesel::pg::PgConnection;
use diesel::result::Error;
use diesel::Connection;
use models;
use models::account::Account;
use models::client::Client;
use models::user::{User,ROLE_ADMIN};
use utils::db_conn;

#[allow(dead_code)]
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

#[allow(dead_code)]
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

// Create models bottom up

#[allow(dead_code)]
pub fn account(conn: &PgConnection) -> (Account, User, Client) {
	let client = models::client::factories::client_attrs().save(conn);

	let user = models::user::factories::user_attrs(&client).save(conn);

	let account = models::account::factories::account_attrs(&user).save(conn);

	(account, user, client)
}

#[allow(dead_code)]
pub fn user(conn: &PgConnection) -> (User, Client) {
	let client = models::client::factories::client_attrs().save(conn);

	let user = models::user::factories::user_attrs(&client).save(conn);

	(user, client)
}

#[allow(dead_code)]
pub fn client(conn: &PgConnection) -> Client {
	models::client::factories::client_attrs().save(conn)
}

// Create top down

#[allow(dead_code)]
pub fn admin_for(conn: &PgConnection, client: &Client) -> User {
	models::user::factories::user_attrs(&client)
		.role(ROLE_ADMIN)
		.save(conn)
}
