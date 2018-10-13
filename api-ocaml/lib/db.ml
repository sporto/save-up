open Core

let database_url = "DATABASE_URL"

let pool =
	match Sys.getenv database_url with
	| Some(url) -> (
		match Caqti_lwt.connect_pool ~max_size:10 (Uri.of_string url) with
		| Ok pool -> pool
		| Error _err -> failwith "Failed to connect"
		)
	| None ->
		failwith "DATABASE_URL not found"


(* 
type error =
	| Database_error of string
 *)
(* Helper method to map Caqti errors to our own error type. 
   val map_db_error : ('a, [> Caqti_error.t ]) result Lwt.t -> ('a, error) result Lwt.t *)
let map_db_error m =
	match%lwt m with
	| Ok a -> Ok a |> Lwt.return
	| Error e -> Error (Caqti_error.show e) |> Lwt.return
	(* | Error e -> Error (Database_error (Caqti_error.show e)) |> Lwt.return *)
