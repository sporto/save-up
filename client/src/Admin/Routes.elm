module Admin.Routes exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = RouteHome
    | RouteInvite
    | RouteNotFound


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map RouteHome top
        , map RouteInvite (s "invite")
        ]


parseLocation : Location -> Route
parseLocation location =
    case parsePath matchers location of
        Just route ->
            route

        Nothing ->
            RouteNotFound
