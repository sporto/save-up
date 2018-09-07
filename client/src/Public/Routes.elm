module Public.Routes exposing (Route(..), parseUrl, pathFor)

import Url exposing (Url)
import Url.Parser exposing (..)


namespace =
    "a/pub"


namespaceAbs =
    "/" ++ namespace


type Route
    = Route_SignIn
    | Route_SignUp


matchers : Parser (Route -> a) a
matchers =
    s "a"
        </> s "pub"
        </> oneOf
                [ map Route_SignIn top
                , map Route_SignIn (s "sign-in")
                , map Route_SignUp (s "sign-up")
                ]


parseUrl : Url -> Route
parseUrl url =
    case parse matchers url of
        Just route ->
            route

        Nothing ->
            Route_SignIn


pathFor : Route -> String
pathFor route =
    case route of
        Route_SignIn ->
            namespaceAbs ++ "/sign-in"

        Route_SignUp ->
            namespaceAbs ++ "/sign-up"

