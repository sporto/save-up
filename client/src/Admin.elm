module Admin exposing (main)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Shared.Flags as Flags
import Shared.Sessions as Sessions


type alias Model =
    { flags : Flags.Flags }


initialModel : Flags.Flags -> Model
initialModel flags =
    { flags = flags }


init : Flags.Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags, Cmd.none )


type Msg
    = SignOut


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SignOut ->
            ( model, Sessions.toJsSignOut () )


subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    navigation model


navigation : Model -> Html Msg
navigation model =
    nav [ class "flex justify-between p-2 bg-black text-white" ]
        [ div [] [ text "KIC" ]
        , div []
            [ text model.flags.token.name
            , a [ href "javascript://", class "text-white ml-3", onClick SignOut ] [ text "Log out" ]
            ]
        ]


main : Program Flags.Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
