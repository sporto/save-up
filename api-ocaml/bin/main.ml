open BatString
open Cohttp
open Core
open Graphql_lwt
open Lib

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
			_token = 
				lchop ~n:7 header
		in
		()

let () =
  Server.start ~port:4010 ~ctx:get_context Graph.schema
    |> Lwt_main.run
