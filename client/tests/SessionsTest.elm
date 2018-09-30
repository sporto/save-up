module SessionsTest exposing (suite)

import Expect exposing (Expectation)
import Result.Extra exposing (isErr)
import Shared.Globals exposing (..)
import Shared.Sessions exposing (..)
import Test exposing (..)
import Time


token =
    "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6bnVsbCwiZXhwIjoxNTY5NzI0OTI3LCJuYW1lIjoiS2ltIiwicm9sZSI6IklOVkVTVE9SIiwidXNlcklkIjo3LCJ1c2VybmFtZSI6ImtpbW15In0.ZoL3jWqu6CBsDqnhHiPMkdOzhPfGD9LUTA1eyHcMcOI"


decodedToken : TokenData
decodedToken =
    { exp = Time.millisToPosix 1569724927000
    , email = Nothing
    , name = "Kim"
    , role = Investor
    , userId = 7
    , username = "kimmy"
    }


decodeTokenTests =
    describe "decodeToken"
        [ test "it decodes" <|
            \_ ->
                Expect.equal (decodeToken token) (Ok decodedToken)
        , test "it doesn't decode an invalid token" <|
            \_ ->
                Expect.true "is error" (decodeToken "abc" |> isErr)
        ]


suite : Test
suite =
    describe "Sessions" [ decodeTokenTests ]
