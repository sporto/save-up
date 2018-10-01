module UI.ConfirmButton exposing (Model, Msg, view)

import Html exposing (..)
import Html.Events exposing (onClick)


type alias Model =
    { state : State }


type State
    = State_Intial
    | State_Engaged


type Msg
    = Click
    | Cancel
    | Commit


init : String -> Model
init id =
    { state = State_Intial }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Click ->
            { model | state = State_Engaged }

        Cancel ->
            { model | state = State_Intial }

        Commit ->
            { model | state = State_Intial }


view : Model -> String -> Html Msg
view model label =
    case model.state of
        State_Intial ->
            div []
                [ button [ onClick Click ]
                    [ text label
                    ]
                ]

        State_Engaged ->
            div []
                [ button [ onClick Commit ] [ text "Yes" ]
                , button [ onClick Cancel ] [ text "Cancel" ]
                ]
