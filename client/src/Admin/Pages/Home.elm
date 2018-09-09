module Admin.Pages.Home exposing (Model, Msg, init, subscriptions, update, view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Shared.Context exposing (Context)


type Msg
    = NoOp


type alias Model =
    {}


newModel =
    {}


init : ( Model, Cmd Msg )
init =
    ( newModel, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Context -> Msg -> Model -> ( Model, Cmd Msg )
update context msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : Context -> Model -> Html msg
view context model =
    section []
        [ h1 [] [ text "Welcome" ]
        , p [ class "mt-3" ] [ text "You don't have any investors, please invite one by clicking the invite link above." ]
        ]
