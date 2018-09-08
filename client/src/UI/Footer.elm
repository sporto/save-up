module UI.Footer exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href)


view =
    footer [ class "mt-8 p-5 bg-grey-dark text-white" ]
        [ text "Copyright 2018"
        ]
