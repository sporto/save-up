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
    { email : String
    , password : String
    }


newSignIn : SignIn
newSignIn =
    { email = ""
    , password = ""
    }


port toJsUseToken : String -> Cmd msg


port toElmSignUpError : (Decode.Value -> msg) -> Sub msg


port toJsSignOut : () -> Cmd msg
