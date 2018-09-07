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
    | Route_Invitation String


matchers : Parser (Route -> a) a
matchers =
    s "a"
        </> s "pub"
        </> oneOf
                [ map Route_SignIn top
                , map Route_SignIn (s segmentSignIn)
                , map Route_SignUp (s segmentSignUp)
                , map Route_Invitation (s segmentInvitation </> string)
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
            namespaceAbs ++ "/" ++ segmentSignIn

        Route_SignUp ->
            namespaceAbs ++ "/" ++ segmentSignUp

        Route_Invitation token ->
            namespaceAbs ++ "/" ++ segmentInvitation ++ "/" ++ token


segmentSignIn =
    "sign-in"


segmentSignUp =
    "sign-up"


segmentInvitation =
    "invitation"
