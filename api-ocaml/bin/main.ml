open Graphql_lwt
open Lib

let () =
  Server.start ~port:4010 ~ctx:(fun _req -> ()) Graph.schema
    |> Lwt_main.run
