module Notifications exposing (Model, Msg, add, addError, addInfo, addSuccess, init, update, view)

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
    { level : Level
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


add : Args -> Notification -> Model -> ( Model, Cmd Msg )
add args not model =
    let
        nextModel =
            { model
                | notifications = nextNotifications
                , nextId = model.nextId + 1
            }

        nextNotifications =
            ( model.nextId, not ) :: model.notifications

        cmd =
            Process.sleep args.dismissIn
                |> Task.perform (\_ -> Dismiss model.nextId)
    in
    ( nextModel, cmd )


addError : Args -> String -> Model -> ( Model, Cmd Msg )
addError args message model =
    model
        |> add args (newError message)


addSuccess : Args -> String -> Model -> ( Model, Cmd Msg )
addSuccess args message model =
    model
        |> add args (newSuccess message)


addInfo : Args -> String -> Model -> ( Model, Cmd Msg )
addInfo args message model =
    model
        |> add args (newInfo message)


newError : String -> Notification
newError message =
    { level = LevelError
    , message = message
    }


newSuccess : String -> Notification
newSuccess message =
    { level = LevelSuccess
    , message = message
    }


newInfo : String -> Notification
newInfo message =
    { level = LevelInfo
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
