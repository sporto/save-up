use hashids::HashIds;

#[allow(dead_code)]
pub fn hash_id(id: i32, resouce_kind: &str) -> String {
    let maybe_ids = HashIds::new_with_salt(resouce_kind.to_string());

    match maybe_ids {
        Ok(ids) => ids.encode(&vec![id as i64]),
        Err(_) => "err".to_string(),
    }
}

#[allow(dead_code)]
pub fn unhash_id(hash_id: &str, resouce_kind: &str) -> i32 {
    let maybe_ids = HashIds::new_with_salt(resouce_kind.to_string());

    match maybe_ids {
        Ok(ids) => {
            let nums = ids.decode(hash_id.to_string());

            match nums.first() {
                Some(n) => *n as i32,
                None => 0,
            }
        }
        Err(_) => 0,
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn hash_id() {
        let res = super::hash_id(1, "User");
        assert_eq!(res, "Y1".to_string())
    }

    fn unhash_id() {
        let res = super::unhash_id("Y1", "User");
        assert_eq!(res, 1)
    }
}
