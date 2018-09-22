module Shared.Routes exposing (Route(..), RouteInAdmin(..), RouteInAdminInAccount(..), RouteInInvestor(..), RouteInPublic(..), isInAnyAdminRoute, parseUrl, pathFor, routeForAdminAccountDeposit, routeForAdminAccountShow, routeForAdminAccountWithdraw, routeForAdminCreateInvestor, routeForAdminHome, routeForAdminInvite, routeForInvestorHome, routeForSignIn, routeForSignUp)

import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = Route_Admin RouteInAdmin
    | Route_Investor RouteInInvestor
    | Route_Public RouteInPublic
    | Route_NotFound


type RouteInPublic
    = RouteInPublic_SignIn
    | RouteInPublic_SignUp
    | RouteInPublic_Invitation String


type RouteInAdmin
    = RouteInAdmin_Home
    | RouteInAdmin_Invite
    | RouteInAdmin_CreateInvestor
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
                [ map Route_Public <| map RouteInPublic_SignIn top
                , map Route_Public <| map RouteInPublic_SignIn <| s segmentSignIn
                , map Route_Public <| map RouteInPublic_SignUp <| s segmentSignUp
                , map Route_Public <| map RouteInPublic_Invitation <| s segmentInvitation </> string
                , map Route_Admin (s segAdmin </> matchersForAdmin)
                , map Route_Investor (s segInvestor </> matchersForInvestor)
                ]


matchersForAdmin : Parser (RouteInAdmin -> a) a
matchersForAdmin =
    oneOf
        [ map RouteInAdmin_Home top
        , map RouteInAdmin_Invite (s segInvite)
        , map RouteInAdmin_CreateInvestor (s segInvestors </> s segNew)
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
    let
        prefix =
            "/" ++ segBasepath ++ "/"
    in
    case route of
        Route_NotFound ->
            prefix

        Route_Public publicRoute ->
            prefix ++ pathInPublic publicRoute

        Route_Admin adminRoute ->
            prefix ++ segAdmin ++ "/" ++ pathForAdminRoute adminRoute

        Route_Investor investorRoute ->
            prefix ++ segInvestor ++ "/" ++ pathForInvestorRoute investorRoute


pathInPublic : RouteInPublic -> String
pathInPublic route =
    case route of
        RouteInPublic_SignIn ->
            segmentSignIn

        RouteInPublic_SignUp ->
            segmentSignUp

        RouteInPublic_Invitation token ->
            segmentInvitation ++ "/" ++ token


pathForAdminRoute : RouteInAdmin -> String
pathForAdminRoute route =
    case route of
        RouteInAdmin_Home ->
            ""

        RouteInAdmin_Invite ->
            segInvite

        RouteInAdmin_CreateInvestor ->
            segInvestors ++ "/" ++ segNew

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


segmentSignIn =
    "sign-in"


segmentSignUp =
    "sign-up"


segmentInvitation =
    "invitation"


segBasepath =
    "a"


segAdmin =
    "admin"


segAccounts =
    "accounts"


segInvestor =
    "investor"


segInvestors =
    "investors"


segInvite =
    "invite"


segDeposit =
    "deposit"


segNew =
    "new"


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


routeForSignIn : Route
routeForSignIn =
    RouteInPublic_SignIn |> Route_Public


routeForSignUp : Route
routeForSignUp =
    RouteInPublic_SignUp |> Route_Public


routeForAdminHome : Route
routeForAdminHome =
    Route_Admin RouteInAdmin_Home


routeForAdminInvite : Route
routeForAdminInvite =
    Route_Admin RouteInAdmin_Invite


routeForAdminCreateInvestor : Route
routeForAdminCreateInvestor =
    Route_Admin RouteInAdmin_CreateInvestor


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


routeForInvestorHome : Route
routeForInvestorHome =
    Route_Investor RouteInInvestor_Home
