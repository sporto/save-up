// use bigdecimal::BigDecimal;
// use Value;

// graphql_scalar!(BigDecimal {
// 	description: "BigDecimal"
 
// 	resolve(&self) -> Value {
// 		Value::string(self.to_string())
// 	}

// 	 from_input_value(v: &InputValue) -> Option<BigDecimal> {
// 		v.as_string_value()
// 			.and_then(|s| s.parse::<BigDecimal>().ok())
// 	}
// });
