module SessionsTest exposing (suite)

import Expect exposing (Expectation)
import Result.Extra exposing (isErr)
import Shared.Globals exposing (..)
import Shared.Sessions exposing (..)
import Test exposing (..)
import Time


token =
    "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InNAcG9ydG81LmNvbSIsImV4cCI6MTU2NzkwNTgzNSwibmFtZSI6IlNlYmFzdGlhbiIsInJvbGUiOiJBRE1JTiIsInVzZXJJZCI6MX0.oM_g37Kyx4Jpy_BkCSxa1WkPr5oTyrZaPpj6qm0mlbI"


decodedToken : TokenData
decodedToken =
    { exp = Time.millisToPosix 1567905835000
    , userId = 1
    , email = "s@porto5.com"
    , name = "Sebastian"
    , role = Admin
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
