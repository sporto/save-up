module Shared.Actions exposing (Action, Actions, batch, endSession, map, none, startSession)


type alias Actions msg =
    List (Action msg)


type Action msg
    = StartSession String
    | EndSession


none : Actions a
none =
    []


startSession token =
    [ StartSession token ]


endSession =
    [ EndSession ]


batch : List (Actions a) -> Actions a
batch =
    List.concat


map : (a -> b) -> Actions a -> Actions b
map tagger =
    List.map (mapAction tagger)


mapAction : (a -> b) -> Action a -> Action b
mapAction tagger action =
    case action of
        StartSession token ->
            StartSession token

        EndSession ->
            EndSession
