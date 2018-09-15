module Shared.Routes exposing (Route(..), parseUrl, pathFor, routeForAccountDeposit, routeForAccountShow, routeForAccountWithdraw)

import Url exposing (Url)
import Url.Parser exposing (..)


namespace =
    "a/admin"


namespaceAbs =
    "/" ++ namespace


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
    s "a"
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
            "/a/"

        Route_Admin adminRoute ->
            "/a/" ++ segAdmin ++ "/" ++ pathForAdminRoute adminRoute


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


routeForAccountShow id =
    RouteInAdmin_Account id RouteInAdminInAccount_Top


routeForAccountDeposit id =
    RouteInAdmin_Account id RouteInAdminInAccount_Deposit


routeForAccountWithdraw id =
    RouteInAdmin_Account id RouteInAdminInAccount_Withdraw
