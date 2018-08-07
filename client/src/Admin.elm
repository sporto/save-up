module Admin exposing (main)

import Admin.Routes as Routes exposing (Route)
import Admin.AppLocation as AppLocation exposing (AppLocation)
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Navigation exposing (Location)
import Shared.Flags as Flags
import Shared.Sessions as Sessions


type alias Model =
    { flags : Flags.Flags
    , currentLocation : AppLocation
    }


initialModel : Flags.Flags -> Location -> Model
initialModel flags location =
    { flags = flags
    , currentLocation = AppLocation.navigationLocationToAppLocation location
    }


init : Flags.Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    ( initialModel flags location
    , Cmd.none
    )


type Msg
    = SignOut
    | OnLocationChange Location


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SignOut ->
            ( model, Sessions.toJsSignOut () )

        OnLocationChange location ->
            ( { model | currentLocation = AppLocation.navigationLocationToAppLocation location }
            , Cmd.none
            )


subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    navigation model


navigation : Model -> Html Msg
navigation model =
    nav [ class "flex justify-between p-4 bg-black text-white" ]
        [ div [] [ text "KIC" ]
        , div []
            [ text model.flags.token.name
            , a [ href "javascript://", class "text-white ml-3", onClick SignOut ] [ text "Log out" ]
            ]
        ]


main : Program Flags.Flags Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
