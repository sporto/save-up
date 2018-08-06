module Shared.GraphQl exposing (..)

import Api.Object
import Api.Object.MutationError
import Graphqelm.Http
import Graphqelm.SelectionSet exposing (SelectionSet, with)
import RemoteData


type alias GraphData a =
    RemoteData.RemoteData (Graphqelm.Http.Error a) a


type alias MutationError =
    { key : String
    , messages : List String
    }


mutationErrorSelection : SelectionSet MutationError Api.Object.MutationError
mutationErrorSelection =
    Api.Object.MutationError.selection MutationError
        |> with Api.Object.MutationError.key
        |> with Api.Object.MutationError.messages
