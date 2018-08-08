module Admin.Routes exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


namespace =
    "admin"

namespaceAbs =
    "/" ++ namespace


type Route
    = Route_Home
    | Route_Invite
    | Route_NotFound


matchers : Parser (Route -> a) a
matchers =
    s namespace
        </> oneOf
                [ map Route_Home top
                , map Route_Invite (s "invite")
                ]


parseLocation : Location -> Route
parseLocation location =
    case parsePath matchers location of
        Just route ->
            route

        Nothing ->
            Route_NotFound


pathFor : Route -> String
pathFor route =
    case route of
        Route_Home ->
            namespaceAbs ++ "/"

        Route_Invite ->
            namespaceAbs ++ "/invite"

        Route_NotFound ->
            namespaceAbs ++ "/"
