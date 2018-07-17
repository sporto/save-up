module Investor exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


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
    = Increment
    | Decrement


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | count = model.count + 1 }, Cmd.none )

        Decrement ->
            ( { model | count = model.count - 1 }, Cmd.none )


subscriptions model =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    { title = "KIC Admin"
    , body =
        [ button [ onClick Increment ] [ text "+1" ]
        , div [] [ text <| String.fromInt model.count ]
        , button [ onClick Decrement ] [ text "-1" ]
        ]
    }


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
