module UI.Flash exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)


error : String -> Html msg
error message =
    div [ class "p-2 text-red" ]
        [ text message
        ]
