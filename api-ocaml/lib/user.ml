type t = {
	id : int;
	name : string;
}


let get_all_query =
	Caqti_request.collect
		Caqti_type.unit
		Caqti_type.(tup2 int string)
		"SELECT id, name FROM users"


let get_all () =
	let get_all' (module C : Caqti_lwt.CONNECTION) =
		C.fold get_all_query (fun (id, name) acc ->
			{ id; name } :: acc
		) () []
	in
	Caqti_lwt.Pool.use get_all' Db.pool 
		|> Db.map_db_error
