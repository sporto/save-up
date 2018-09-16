module Investor.Pages.Home exposing (Model, Msg, init, subscriptions, update, view)

import Html exposing (..)
import Html.Attributes exposing (class, href, name, src, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Shared.Actions as Actions
import Shared.Globals exposing (..)


type alias Model =
    ()


initialModel : Flags -> Model
initialModel flags =
    ()


type Msg
    = NoOp


type alias Returns =
    ( Model, Cmd Msg, Actions.Actions Msg )


init : Context -> Returns
init context =
    ( initialModel context.flags, Cmd.none, Actions.none )


update : Context -> Msg -> Model -> Returns
update context msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none, Actions.none )


subscriptions model =
    Sub.none


view : Context -> Model -> Html Msg
view context model =
    div []
        [ h1 [ class "mt-6" ] [ text "Your account" ]
        , div [ class "mt-8 flex justify-center" ]
            [ img [ src "https://via.placeholder.com/600x320" ] []
            ]
        ]
