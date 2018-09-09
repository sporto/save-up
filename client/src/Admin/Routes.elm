module Admin.Routes exposing (Route(..), RouteAccount(..), parseUrl, pathFor, routeForAccountDeposit, routeForAccountShow, routeForAccountWithdraw)

import Url exposing (Url)
import Url.Parser exposing (..)


namespace =
    "a/admin"


namespaceAbs =
    "/" ++ namespace


type Route
    = Route_Home
    | Route_Invite
    | Route_NotFound
    | Route_Account Int RouteAccount


type RouteAccount
    = RouteAccount_Top
    | RouteAccount_Deposit
    | RouteAccount_Withdraw


matchers : Parser (Route -> a) a
matchers =
    s "a"
        </> s "admin"
        </> oneOf
                [ map Route_Home top
                , map Route_Invite (s segInvite)
                , map Route_Account (s segAccounts </> int </> accountsMatchers)
                ]


accountsMatchers : Parser (RouteAccount -> a) a
accountsMatchers =
    oneOf
        [ map RouteAccount_Top top
        , map RouteAccount_Deposit (s segDeposit)
        , map RouteAccount_Withdraw (s segWithdraw)
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
            namespaceAbs ++ "/"

        Route_Home ->
            namespaceAbs ++ "/"

        Route_Invite ->
            namespaceAbs ++ "/" ++ segInvite

        Route_Account id sub ->
            let
                prefix =
                    namespaceAbs ++ "/" ++ segAccounts ++ "/" ++ String.fromInt id
            in
            case sub of
                RouteAccount_Top ->
                    prefix

                RouteAccount_Deposit ->
                    prefix ++ "/" ++ segDeposit

                RouteAccount_Withdraw ->
                    prefix ++ "/" ++ segWithdraw


segAccounts =
    "accounts"


segInvite =
    "invite"


segDeposit =
    "deposit"


segWithdraw =
    "withdraw"


routeForAccountShow id =
    Route_Account id RouteAccount_Top


routeForAccountDeposit id =
    Route_Account id RouteAccount_Deposit


routeForAccountWithdraw id =
    Route_Account id RouteAccount_Withdraw
