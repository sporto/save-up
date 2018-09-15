module Investor.Pages.Home exposing (Model, Msg, init, subscriptions, update, view)

import Html exposing (..)
import Html.Attributes exposing (class, href, name, src, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Shared.Context exposing (Context)
import Shared.Flags as Flags exposing (Flags)


type alias Model =
    ()


initialModel : Flags.Flags -> Model
initialModel flags =
    ()


type Msg
    = NoOp


init : Context -> ( Model, Cmd Msg )
init context =
    ( initialModel context.flags, Cmd.none )


update : Context -> Msg -> Model -> ( Model, Cmd Msg )
update context msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


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
