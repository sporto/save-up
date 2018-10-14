open BatString
open Cohttp
open Core
open Graphql_lwt
open Lib
open Jwt

let decode_token token =
	try
		Ok (Jwt.t_of_token token)
	with
		Bad_token -> Error "Bad token"

let get_context (req: Cohttp.Request.t) =
	let
		authHeader = 
			req
				|> Request.headers 
				|> (Fn.flip Header.get) "Authorization"
	in
	match authHeader with
	| None -> ()
	| Some(header) ->
		let
			token = 
				(* e.g. Bearer abc123... *)
				lchop ~n:7 header
		in
		match decode_token token with
			| Ok(_data) -> ()
			| Error(_) -> ()

let () =
  Server.start ~port:4010 ~ctx:get_context Graph.schema
    |> Lwt_main.run
