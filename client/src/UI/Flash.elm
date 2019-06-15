module UI.Flash exposing
    ( error
    , success
    )

import Html exposing (..)
import Html.Attributes exposing (class)


error : String -> Html msg
error message =
    div [ class "p-2 text-red-500 border-red-500 border my-4" ]
        [ text message
        ]


success : String -> Html msg
success message =
    div [ class "p-2 text-green-500 border-green-500 border my-4" ]
        [ text message
        ]
