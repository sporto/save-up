module Shared.Actions exposing (Action(..), Actions, addErrorNotification, addNotification, addSuccessNotification, batch, endSession, map, none, startSession)

import Notifications
import Shared.Css as Css


type alias Actions msg =
    List (Action msg)


type Action msg
    = Action_StartSession String
    | Action_EndSession
    | Action_AddNotification Notifications.Notification


none : Actions a
none =
    []


addNotification : Notifications.Notification -> Actions a
addNotification notification =
    [ Action_AddNotification notification ]


addErrorNotification : String -> Actions a
addErrorNotification label =
    addNotification (Notifications.newError Css.notificationArgs label)


addSuccessNotification : String -> Actions a
addSuccessNotification label =
    addNotification (Notifications.newSuccess Css.notificationArgs label)


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

        Action_AddNotification not ->
            Action_AddNotification not
