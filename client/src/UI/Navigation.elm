module UI.Navigation exposing
    ( logo
    , signOut
    )

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)


logo =
    div [ class "font-semibold" ]
        [ text "SaveUp" ]


signOut : msg -> Html msg
signOut msg =
    a [ href "#", class "text-white ml-3", onClick msg ]
        [ text "Log out"
        , i [ class "fas fa-sign-out-alt ml-2" ] []
        ]
