module Investor exposing (main)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Shared.Tokens as Tokens


type alias Flags =
    ()


type alias Model =
    { count : Int }


initialModel : Model
initialModel =
    { count = 0 }


init flags =
    ( initialModel, Cmd.none )


type Msg
    = SignOut


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SignOut ->
            ( model, Tokens.toJsSignOut () )


subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    navigation model


navigation : Model -> Html Msg
navigation model =
    nav [ class "flex justify-between p-2 bg-black text-white" ]
        [ div [] [ text "KIC" ]
        , div [] [ a [ href "javascript://", class "text-white", onClick SignOut ] [ text "Log out" ] ]
        ]


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
