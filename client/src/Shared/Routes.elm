module Shared.Routes exposing (Route(..), RouteInAdmin(..), RouteInAdminInAccount(..), isInAnyAdminRoute, parseUrl, pathFor, routeForAdminAccountDeposit, routeForAdminAccountShow, routeForAdminAccountWithdraw, routeForAdminHome, routeForAdminInvite)

import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = Route_Admin RouteInAdmin
    | Route_NotFound


type RouteInAdmin
    = RouteInAdmin_Home
    | RouteInAdmin_Invite
    | RouteInAdmin_Account Int RouteInAdminInAccount


type RouteInAdminInAccount
    = RouteInAdminInAccount_Top
    | RouteInAdminInAccount_Deposit
    | RouteInAdminInAccount_Withdraw


matchers : Parser (Route -> a) a
matchers =
    s segBasepath
        </> oneOf
                [ map Route_Admin (s segAdmin </> matchersForAdmin)
                ]


matchersForAdmin : Parser (RouteInAdmin -> a) a
matchersForAdmin =
    oneOf
        [ map RouteInAdmin_Home top
        , map RouteInAdmin_Invite (s segInvite)
        , map RouteInAdmin_Account (s segAccounts </> int </> matchersForAdminInAccount)
        ]


matchersForAdminInAccount : Parser (RouteInAdminInAccount -> a) a
matchersForAdminInAccount =
    oneOf
        [ map RouteInAdminInAccount_Top top
        , map RouteInAdminInAccount_Deposit (s segDeposit)
        , map RouteInAdminInAccount_Withdraw (s segWithdraw)
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
        Route_NotFound ->
            "/" ++ segBasepath ++ "/"

        Route_Admin adminRoute ->
            "/" ++ segBasepath ++ "/" ++ segAdmin ++ "/" ++ pathForAdminRoute adminRoute


pathForAdminRoute : RouteInAdmin -> String
pathForAdminRoute route =
    case route of
        RouteInAdmin_Home ->
            ""

        RouteInAdmin_Invite ->
            segInvite

        RouteInAdmin_Account id sub ->
            let
                prefix =
                    segAccounts ++ "/" ++ String.fromInt id
            in
            case sub of
                RouteInAdminInAccount_Top ->
                    prefix

                RouteInAdminInAccount_Deposit ->
                    prefix ++ "/" ++ segDeposit

                RouteInAdminInAccount_Withdraw ->
                    prefix ++ "/" ++ segWithdraw


segBasepath =
    "a"


segAdmin =
    "admin"


segAccounts =
    "accounts"


segInvite =
    "invite"


segDeposit =
    "deposit"


segWithdraw =
    "withdraw"



-- Query Routes


isInAnyAdminRoute : Route -> Bool
isInAnyAdminRoute route =
    case route of
        Route_Admin _ ->
            True

        _ ->
            False



-- Get Routes


routeForAdminHome : Route
routeForAdminHome =
    Route_Admin RouteInAdmin_Home


routeForAdminInvite : Route
routeForAdminInvite =
    Route_Admin RouteInAdmin_Invite


routeForAdminAccountShow : Int -> Route
routeForAdminAccountShow id =
    RouteInAdmin_Account id RouteInAdminInAccount_Top
        |> Route_Admin


routeForAdminAccountDeposit : Int -> Route
routeForAdminAccountDeposit id =
    RouteInAdmin_Account id RouteInAdminInAccount_Deposit
        |> Route_Admin


routeForAdminAccountWithdraw : Int -> Route
routeForAdminAccountWithdraw id =
    RouteInAdmin_Account id RouteInAdminInAccount_Withdraw
        |> Route_Admin
