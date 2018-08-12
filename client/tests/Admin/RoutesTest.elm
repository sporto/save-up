module Admin.RoutesTest exposing (..)

import Admin.Routes exposing (..)
import Expect exposing (Expectation)
import Test exposing (..)
import Navigation exposing (Location)


newLocation : Location
newLocation =
    { href = ""
    , host = ""
    , hostname = ""
    , protocol = ""
    , origin = ""
    , port_ = ""
    , pathname = "/app/admin/"
    , search = ""
    , hash = ""
    , username = ""
    , password = ""
    }


parsingTest testCase pathname expected =
    test testCase <|
        \_ ->
            let
                location =
                    { newLocation | pathname = pathname }

                actual =
                    parseLocation location
            in
                Expect.equal actual expected


parsingTests : Test
parsingTests =
    describe "parse"
        [ parsingTest "home" "/app/admin" Route_Home
        , parsingTest "home with trailing" "/app/admin/" Route_Home
        ]


suite : Test
suite =
    describe "Admin.Routes" [ parsingTests ]
