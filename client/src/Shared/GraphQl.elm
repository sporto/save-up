module Shared.GraphQl exposing (..)

import Graphqelm.Http
import RemoteData


type alias GraphData a =
    RemoteData.RemoteData (Graphqelm.Http.Error a) a


type alias MutationError =
    { key : String
    , messages : List String
    }
