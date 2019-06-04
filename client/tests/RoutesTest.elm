module RoutesTest exposing (suite)

import Expect exposing (Expectation)
import Shared.Routes exposing (..)
import Test exposing (..)
import Url exposing (Url)


newUrl : Url
newUrl =
    { protocol = Url.Http
    , host = ""
    , port_ = Nothing
    , path = "/app/admin/"
    , query = Nothing
    , fragment = Nothing
    }


parsingTest testCase path expected =
    test testCase <|
        \_ ->
            let
                url =
                    { newUrl | path = path }

                actual =
                    parseUrl url
            in
            Expect.equal actual expected


parsingTests : Test
parsingTests =
    describe "parse"
        [ parsingTest "home" "/admin" routeForAdminHome
        , parsingTest "home with trailing" "/admin/" routeForAdminHome
        ]


suite : Test
suite =
    describe "Routes" [ parsingTests ]
