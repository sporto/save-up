open Graphql_lwt
open Cohttp
open Lib
open Core

let get_context (req: Cohttp.Request.t) =
	let
		authHeader = 
			req
				|> Request.headers 
				|> (Fn.flip Header.get) "Authorization"
	in
	match authHeader with
	| None -> ()
	| Some(_header) -> ()

let () =
  Server.start ~port:4010 ~ctx:get_context Graph.schema
    |> Lwt_main.run
