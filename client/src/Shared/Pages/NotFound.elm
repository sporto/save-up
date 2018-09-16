module Shared.Pages.NotFound exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Shared.AppLocation exposing (AppLocation)
import Shared.Globals exposing (..)
import Shared.Routes as Routes


view : Maybe Authentication -> AppLocation -> Html msg
view maybeAuth currentLocation =
    section [ class "p-8 flex flex-col items-center" ]
        [ h1 [ class "text-4xl" ] [ text "Not found" ]
        , p [ class "mt-4" ] (links maybeAuth)
        ]


links : Maybe Authentication -> List (Html msg)
links maybeAuth =
    case maybeAuth of
        Nothing ->
            [ a [ href (Routes.pathFor Routes.routeForSignIn) ] [ text "Sign in" ]
            ]

        Just auth ->
            let
                home =
                    case auth.data.role of
                        Admin ->
                            Routes.routeForAdminHome

                        Investor ->
                            Routes.routeForInvestorHome
            in
            [ a [ href (Routes.pathFor home) ] [ text "Home" ]
            ]
