module UI.Flash exposing (error)

import Html exposing (..)
import Html.Attributes exposing (class)


error : String -> Html msg
error message =
    div [ class "p-2 text-red border-red border mb-4" ]
        [ text message
        ]
