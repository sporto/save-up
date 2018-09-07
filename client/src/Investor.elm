module Investor exposing (main)

import Browser exposing (UrlRequest)
import Browser.Navigation
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Shared.Sessions as Sessions
import UI.Navigation as Navigation
import Url exposing (Url)


type alias Flags =
    ()


type alias Model =
    { count : Int }


initialModel : Model
initialModel =
    { count = 0 }


init : Flags -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    ( initialModel, Cmd.none )


type Msg
    = SignOut
    | OnUrlChange Url
    | OnUrlRequest UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SignOut ->
            ( model, Sessions.toJsSignOut () )

        OnUrlRequest request ->
            ( model, Cmd.none )

        OnUrlChange url ->
            ( model, Cmd.none )


subscriptions model =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    { title = "SaveUp"
    , body = [ navigation model ]
    }


navigation : Model -> Html Msg
navigation model =
    nav [ class "flex p-4 bg-blue text-white" ]
        [ Navigation.logo
        , div
            [ class "ml-8 flex-grow" ]
            []
        , div []
            [ Navigation.signOut SignOut
            ]
        ]


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        , onUrlRequest = OnUrlRequest
        , onUrlChange = OnUrlChange
        }
