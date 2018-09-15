module Investor.Routes exposing (Route(..), parseUrl, pathFor)

import Url exposing (Url)
import Url.Parser exposing (..)


namespace =
    "a/investor"


namespaceAbs =
    "/" ++ namespace


type Route
    = Route_Home
    | Route_NotFound


matchers : Parser (Route -> a) a
matchers =
    s "a"
        </> s "investor"
        </> oneOf
                [ map Route_Home top
                ]


parseUrl : Url -> Route
parseUrl url =
    case parse matchers url of
        Just route ->
            route

        Nothing ->
            Route_NotFound


pathFor : Route -> String
pathFor route =
    case route of
        Route_Home ->
            namespaceAbs ++ "/"

        Route_NotFound ->
            namespaceAbs ++ "/"
