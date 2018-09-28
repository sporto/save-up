module UI.PublicLinks exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href, name, type_, value)
import Maybe.Extra
import Shared.Globals exposing (..)
import Shared.Routes as Routes


view : PublicContext -> Html msg
view context =
    let
        links =
            [ signIn context
            , signUp context
            , forgotPassword context
            ]
                |> Maybe.Extra.values
                |> List.map (p [ class "mt-2" ])
    in
    div [ class "mt-4 text-sm" ]
        links


signIn context =
    let
        route =
            Routes.routeForSignIn
    in
    if context.currentLocation.route == route then
        Nothing

    else
        Just
            [ text "Already signed up? "
            , a [ href (Routes.pathFor route) ] [ text "Sign in" ]
            ]


signUp context =
    let
        route =
            Routes.routeForSignUp
    in
    if context.currentLocation.route == route then
        Nothing

    else
        Just
            [ a [ href (Routes.pathFor route) ] [ text "Sign up" ]
            ]


forgotPassword context =
    let
        route =
            Routes.routeForRequestPasswordReset
    in
    if context.currentLocation.route == route then
        Nothing

    else
        Just
            [ a [ href (Routes.pathFor route) ] [ text "Forgotten password?" ]
            ]
