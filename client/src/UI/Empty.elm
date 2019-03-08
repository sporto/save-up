module UI.Empty exposing
    ( graphError
    , loading
    , noData
    )

import Html exposing (..)
import Html.Attributes exposing (class)
import UI.Icons as Icons


graphError error =
    div []
        [ text "Something went wrong"
        ]


loading =
    div [ class "my-4 flex justify-center" ]
        [ Icons.spinner
        ]


noData message =
    div [ class "my-4 flex justify-center" ]
        [ text message
        ]
