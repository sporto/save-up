open BatString
open Cohttp
open Core
open Graphql_lwt
open Lib
open Jwto

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

module Graphql_cohttp_lwt =
	Graphql_cohttp.Make (Graphql_lwt.Schema) (Cohttp_lwt_unix.IO) (Cohttp_lwt.Body)

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
	let callback =
  		Graphql_cohttp_lwt.make_callback (fun _req -> ()) schema 
	in
	let server =
		Cohttp_lwt_unix.Server.make_response_action ~callback ()
	in
	let mode = 
		`TCP (`Port 8080) 
	in
  	Cohttp_lwt_unix.Server.create ~on_exn ~mode server
  		|> Lwt_main.run
