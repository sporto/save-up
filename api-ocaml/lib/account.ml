open Core

type t = {
	id : int;
	name : string;
}

let get_account_query =
	Caqti_request.find_opt
		Caqti_type.int
		Caqti_type.(tup2 int string)
		"SELECT id, name FROM accounts WHERE id = ?"


let tuple_to_account (id, name) =
	{id; name } 


(* (Account.t option, string) result io *)
let find_account id =
	let
		op (module C : Caqti_lwt.CONNECTION) =
			C.find_opt get_account_query id
	in
	let
		to_account =
			Lwt.map
				(Result.map ~f:
					(Option.map ~f:tuple_to_account)
				)
	in
	Caqti_lwt.Pool.use op Db.pool
		|> Db.map_db_error
		|> to_account
