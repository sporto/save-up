open BatString
open Cohttp
open Core
open Graphql_lwt
open Lib
open Jwto

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
		match Jwto.decode token with
			| Ok(_data) -> ()
			| Error(_) -> ()

let make_context _ = ()

module Graphql_cohttp_lwt =
	Graphql_cohttp.Make (Graphql_lwt.Schema) (Cohttp_lwt_unix.IO) (Cohttp_lwt.Body)


let callback _conn req body =
	let req_path =
		Cohttp.Request.uri req |> Uri.path 
	in
	let path_parts =
		Str.(split (regexp "/") req_path)
	in
	match req.meth, path_parts with
  	| `POST, ["app";"graphql"] ->
		Graphql_cohttp_lwt.execute_request
			Graph_app.schema
			(make_context req)
			req
			body
  	| _ ->
	  	let response =
		  	Cohttp.Response.make ~status:`Not_found ()
		in
    	let body =
			Cohttp_lwt.Body.of_string "Not Found"
		in
    	Lwt.return (`Response (response, body))

let () =
	let on_exn = function
		| Unix.Unix_error (error, func, arg) ->
			Logs.warn (fun m ->
			m  "Client connection error %s: %s(%S)"
			(Unix.error_message error) func arg
		)
		| exn ->
			Logs.err (fun m -> m "Unhandled exception: %a" Fmt.exn exn)
	in
	let server =
		Cohttp_lwt_unix.Server.make_response_action ~callback ()
	in
	let mode = 
  		`TCP (`Port 8080)
	in
  	Cohttp_lwt_unix.Server.create ~on_exn ~mode server
		|> Lwt_main.run
