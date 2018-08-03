use juniper::Value;
use chrono::NaiveDate;

// struct UserID(String);

// graphql_scalar!(NaiveDate {
// 	description: "NaiveDate"

// 	resolve(&self) -> Value {
// 		Value::string(self.format("%Y-%m-%d").to_string())
// 	}

// 	from_input_value(v: &InputValue) -> Option<NaiveDate> {
// 		v.as_string_value()
// 			.and_then(|s| NaiveDate::parse_from_str(s, "%Y-%m-%d").ok())
// 	}
// });
