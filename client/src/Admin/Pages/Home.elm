module Admin.Pages.Home exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)


view : Html msg
view =
    section []
        [ h1 [] [ text "Welcome" ]
        , p [ class "mt-3" ] [ text "You don't have any investors, please invite one by clicking the invite link above." ]
        ]
