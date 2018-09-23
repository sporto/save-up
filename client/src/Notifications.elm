module Notifications exposing (Model, Msg, Notification, add, args, init, newError, newInfo, newSuccess, update, view)

import Html exposing (..)
import Process
import Task


type alias Model =
    { notifications : List ( Int, Notification )
    , nextId : Int
    }


newModel : Model
newModel =
    { notifications = []
    , nextId = 1
    }


type alias Notification =
    { args : Args
    , level : Level
    , message : String
    }


type Level
    = LevelError
    | LevelInfo
    | LevelSuccess


init : ( Model, Cmd Msg )
init =
    ( newModel
    , Cmd.none
    )


type Msg
    = NoOp
    | Dismiss Int


type alias Args =
    { dismissIn : Float }


args : Args
args =
    { dismissIn = 2000 }


add : Notification -> Model -> ( Model, Cmd Msg )
add not model =
    let
        nextModel =
            { model
                | notifications = nextNotifications
                , nextId = model.nextId + 1
            }

        nextNotifications =
            ( model.nextId, not ) :: model.notifications

        cmd =
            Process.sleep not.args.dismissIn
                |> Task.perform (\_ -> Dismiss model.nextId)
    in
    ( nextModel, cmd )


newError : Args -> String -> Notification
newError arguments message =
    { args = arguments
    , level = LevelError
    , message = message
    }


newSuccess : Args -> String -> Notification
newSuccess arguments message =
    { args = arguments
    , level = LevelSuccess
    , message = message
    }


newInfo : Args -> String -> Notification
newInfo arguments message =
    { args = arguments
    , level = LevelInfo
    , message = message
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Dismiss id ->
            let
                nextModel =
                    { model
                        | notifications = nextNotifications
                    }

                nextNotifications =
                    List.filter (\( notId, _ ) -> notId /= id) model.notifications
            in
            ( newModel, Cmd.none )



--Views


view : Model -> Html msg
view model =
    div [] (List.map notification model.notifications)


notification : ( Int, Notification ) -> Html msg
notification ( id, not ) =
    div []
        [ text not.message
        ]
