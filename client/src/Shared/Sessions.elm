port module Shared.Sessions exposing (..)

import Api.InputObject
import Json.Decode as Decode


type alias SignUp =
    Api.InputObject.SignUp


newSignUp : SignUp
newSignUp =
    { email = ""
    , name = ""
    , password = ""
    , timezone = "Australia/Melbourne"
    }


type alias SignIn =
    Api.InputObject.SignIn


newSignIn : SignIn
newSignIn =
    { email = ""
    , password = ""
    }


port toJsUseToken : String -> Cmd msg


port toJsSignOut : () -> Cmd msg
