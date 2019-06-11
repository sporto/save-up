module UI.Footer exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href)


view =
    footer [ class "flex-no-shrink mt-8 p-5 bg-gray-800 text-white" ]
        [ text "Copyright 2018"
        ]
