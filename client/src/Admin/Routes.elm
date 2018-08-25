module Admin.Routes exposing (Route(..), matchers, namespace, namespaceAbs, parseLocation, pathFor)

import Navigation exposing (Location)
import UrlParser exposing (..)


namespace =
    "app/admin"


namespaceAbs =
    "/" ++ namespace


type Route
    = Route_Home
    | Route_Invite
    | Route_NotFound


matchers : Parser (Route -> a) a
matchers =
    s "app"
        </> s "admin"
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
