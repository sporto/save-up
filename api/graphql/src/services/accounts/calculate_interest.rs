use bigdecimal::BigDecimal;
use bigdecimal::ToPrimitive;
use bigdecimal::FromPrimitive;
use chrono::prelude::*;
use diesel::pg::PgConnection;
use failure::Error;
use models::cents::Cents;

pub fn call(
	balance: Cents,
	yearly_interest: &BigDecimal,
	from: NaiveDateTime,
	to: NaiveDateTime,
) -> Result<Cents, Error> {
	let rate =
		BigDecimal::to_f64(&yearly_interest).ok_or(format_err!("Failed to unwrap yearly interest"))?;

	Ok(Cents(0))
}

#[cfg(test)]
mod test {
	use super::*;

	#[test]
	fn it_calculates_the_interest() {}

	#[test]
	fn compound_interest_is_same_as_one() {
		let initial_balance = Cents(100);
		let rate = BigDecimal::from_f32(20.0).unwrap();

		let a = NaiveDate::from_ymd(2016, 1, 1).and_hms(0, 0, 0);
		let b = NaiveDate::from_ymd(2016, 2, 1).and_hms(0, 0, 0);
		let c = NaiveDate::from_ymd(2016, 3, 1).and_hms(0, 0, 0);

		let interest_a_to_b = call(initial_balance, &rate, a, b).unwrap();
		let intermediate_balance = initial_balance + interest_a_to_b;
		let interest_b_to_c = call(intermediate_balance, &rate, b, c).unwrap();
		let final_balance_1 = initial_balance + interest_a_to_b + interest_b_to_c;

		let interest_a_to_c = call(initial_balance, &rate, a, c).unwrap();
		let final_balance_2 = initial_balance + interest_a_to_c;

		assert_eq!(final_balance_1, final_balance_2)
	}
}
