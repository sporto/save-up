use bigdecimal::BigDecimal;
// use bigdecimal::FromPrimitive;
use bigdecimal::ToPrimitive;
use chrono::prelude::*;
use failure::Error;
use models::cents::Cents;

pub fn call(
	balance: Cents,
	yearly_interest: &BigDecimal,
	from: NaiveDateTime,
	to: NaiveDateTime,
) -> Result<Cents, Error> {
	let rate: f64 = BigDecimal::to_f64(&yearly_interest)
		.ok_or(format_err!("Failed to unwrap yearly interest"))?;

	let rate_perc = rate / 100.0;

	let day_diff_duration = to.signed_duration_since(from);
	let day_diff = day_diff_duration.num_days() as i32;

	println!("day_diff = {:?}", day_diff);

	let daily_rate = ((1.0 + rate_perc).powf(1.0 / 365.0)) - 1.0;

	println!("daily_rate = {:?}", daily_rate);

	let principal: f64 = match balance {
		Cents(p) => p as f64,
	};

	println!("principal = {:?}", principal);

	let new_principal = principal * (1.0 + daily_rate).powi(day_diff);

	println!("new_principal = {:?}", new_principal);

	let interest = new_principal - principal;

	Ok(Cents(interest as i64))
}

#[cfg(test)]
mod test {
	use super::*;
	use range_check::Contains;

	#[test]
	fn it_calculates_the_interest_at_30() {
		let initial_balance = Cents(1000);
		let rate = BigDecimal::from_f32(30.0).unwrap();

		let a = NaiveDate::from_ymd(2016, 1, 1).and_hms(0, 0, 0);
		let b = NaiveDate::from_ymd(2017, 1, 1).and_hms(0, 0, 0);

		let Cents(interest) = call(initial_balance, &rate, a, b).unwrap();

		assert_eq!(interest, 300);
	}

	#[test]
	fn it_calculates_the_interest_at_50() {
		let initial_balance = Cents(2000);
		let rate = BigDecimal::from_f32(50.0).unwrap();

		let a = NaiveDate::from_ymd(2016, 1, 1).and_hms(0, 0, 0);
		let b = NaiveDate::from_ymd(2017, 1, 1).and_hms(0, 0, 0);

		let Cents(interest) = call(initial_balance, &rate, a, b).unwrap();

		let range = 995..1005;
		assert!(range.contains(&interest));
	}

	#[test]
	fn it_calculates_half_year() {
		let initial_balance = Cents(1000);
		let rate = BigDecimal::from_f32(20.0).unwrap();

		let a = NaiveDate::from_ymd(2016, 1, 1).and_hms(0, 0, 0);
		let b = NaiveDate::from_ymd(2016, 7, 2).and_hms(0, 0, 0);

		let Cents(interest) = call(initial_balance, &rate, a, b).unwrap();

		let range = 95..105;
		assert!(range.contains(&interest));
	}

	#[test]
	fn compound_interest_is_same_as_one() {
		let initial_balance = Cents(1000);
		let rate = BigDecimal::from_f32(30.0).unwrap();

		let a = NaiveDate::from_ymd(2016, 1, 1).and_hms(0, 0, 0);
		let b = NaiveDate::from_ymd(2016, 2, 1).and_hms(0, 0, 0);
		let c = NaiveDate::from_ymd(2016, 3, 1).and_hms(0, 0, 0);

		let interest_a_to_b = call(initial_balance, &rate, a, b).unwrap();
		let intermediate_balance = initial_balance + interest_a_to_b;
		let interest_b_to_c = call(intermediate_balance, &rate, b, c).unwrap();
		let Cents(final_balance_1) = initial_balance + interest_a_to_b + interest_b_to_c;

		let interest_a_to_c = call(initial_balance, &rate, a, c).unwrap();
		let Cents(final_balance_2) = initial_balance + interest_a_to_c;

		let range = (final_balance_1 - 5)..(final_balance_1 + 5);
		assert!(range.contains(&final_balance_2));
	}
}
