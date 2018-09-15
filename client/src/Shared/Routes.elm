module Shared.Routes exposing (Route(..), RouteInAdmin(..), RouteInAdminInAccount(..), RouteInInvestor(..), isInAnyAdminRoute, parseUrl, pathFor, routeForAdminAccountDeposit, routeForAdminAccountShow, routeForAdminAccountWithdraw, routeForAdminHome, routeForAdminInvite)

import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = Route_Admin RouteInAdmin
    | Route_Investor RouteInInvestor
    | Route_NotFound


type RouteInAdmin
    = RouteInAdmin_Home
    | RouteInAdmin_Invite
    | RouteInAdmin_Account Int RouteInAdminInAccount


type RouteInAdminInAccount
    = RouteInAdminInAccount_Top
    | RouteInAdminInAccount_Deposit
    | RouteInAdminInAccount_Withdraw


type RouteInInvestor
    = RouteInInvestor_Home


matchers : Parser (Route -> a) a
matchers =
    s segBasepath
        </> oneOf
                [ map Route_Admin (s segAdmin </> matchersForAdmin)
                , map Route_Investor (s segInvestor </> matchersForInvestor)
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


matchersForInvestor : Parser (RouteInInvestor -> a) a
matchersForInvestor =
    oneOf
        [ map RouteInInvestor_Home top
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

        Route_Investor investorRoute ->
            "/" ++ segBasepath ++ "/" ++ segInvestor ++ "/" ++ pathForInvestorRoute investorRoute


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


pathForInvestorRoute : RouteInInvestor -> String
pathForInvestorRoute route =
    case route of
        RouteInInvestor_Home ->
            ""


segBasepath =
    "a"


segAdmin =
    "admin"


segAccounts =
    "accounts"


segInvestor =
    "investor"


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
