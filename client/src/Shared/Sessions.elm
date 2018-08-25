port module Shared.Sessions exposing (SignIn, SignUp, newSignIn, newSignUp, toJsSignOut, toJsUseToken)

import ApiPub.InputObject
import Json.Decode as Decode


type alias SignUp =
    ApiPub.InputObject.SignUp


newSignUp : SignUp
newSignUp =
    { email = ""
    , name = ""
    , password = ""
    }


type alias SignIn =
    ApiPub.InputObject.SignIn


newSignIn : SignIn
newSignIn =
    { email = ""
    , password = ""
    }


port toJsUseToken : String -> Cmd msg


port toJsSignOut : () -> Cmd msg
