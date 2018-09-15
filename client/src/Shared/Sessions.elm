port module Shared.Sessions exposing (SignIn, SignUp, asEmailInSignUp, asNameInSignUp, asPasswordInSignUp, endSession, newSignIn, newSignUp, startSession)

import ApiPub.InputObject
import Browser.Navigation as Nav
import Json.Decode as Decode
import Shared.Globals exposing (..)
import Shared.Routes as Routes


type alias SignUp =
    ApiPub.InputObject.SignUp


newSignUp : SignUp
newSignUp =
    { email = ""
    , name = ""
    , password = ""
    }


asEmailInSignUp : SignUp -> String -> SignUp
asEmailInSignUp signUp email =
    { signUp | email = email }


asNameInSignUp : SignUp -> String -> SignUp
asNameInSignUp signUp name =
    { signUp | name = name }


asPasswordInSignUp : SignUp -> String -> SignUp
asPasswordInSignUp signUp password =
    { signUp | password = password }


type alias SignIn =
    ApiPub.InputObject.SignIn


newSignIn : SignIn
newSignIn =
    { email = ""
    , password = ""
    }


startSession : Nav.Key -> String -> Cmd msg
startSession navKey token =
    let
        role =
            Admin

        route =
            case role of
                Admin ->
                    Routes.routeForAdminHome

                Investor ->
                    Routes.routeForInvestorHome

        path =
            Routes.pathFor route
    in
    Cmd.batch
        [ toJsStoreToken token
        , Nav.pushUrl navKey path
        ]


endSession : Nav.Key -> Cmd msg
endSession navKey =
    let
        path =
            Routes.pathFor Routes.routeForSignIn
    in
    Cmd.batch
        [ toJsRemoveToken ()
        , Nav.pushUrl navKey path
        ]


port toJsStoreToken : String -> Cmd msg


port toJsRemoveToken : () -> Cmd msg
