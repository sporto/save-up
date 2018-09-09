module UI.Empty exposing (graphError)

import Html exposing (..)
import Html.Attributes exposing (class)


graphError error =
    div []
        [ text "Something went wrong"
        ]
