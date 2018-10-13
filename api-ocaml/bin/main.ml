open Graphql_lwt
open Lib

let () =
  Server.start ~ctx:(fun _req -> ()) Graph.schema
    |> Lwt_main.run
