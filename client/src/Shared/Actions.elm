module Shared.Actions exposing (Action(..), Actions, batch, endSession, map, none, startSession)


type alias Actions msg =
    List (Action msg)


type Action msg
    = Action_StartSession String
    | Action_EndSession


none : Actions a
none =
    []


startSession token =
    [ Action_StartSession token ]


endSession =
    [ Action_EndSession ]


batch : List (Actions a) -> Actions a
batch =
    List.concat


map : (a -> b) -> Actions a -> Actions b
map tagger =
    List.map (mapAction tagger)


mapAction : (a -> b) -> Action a -> Action b
mapAction tagger action =
    case action of
        Action_StartSession token ->
            Action_StartSession token

        Action_EndSession ->
            Action_EndSession
