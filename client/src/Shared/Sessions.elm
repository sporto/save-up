port module Shared.Sessions exposing (..)


type alias SignUp =
    { email : String
    , name : String
    , password : String
    , timezone : String
    }


newSignUp : SignUp
newSignUp =
    { email = ""
    , name = ""
    , password = ""
    , timezone = "Australia/Melbourne"
    }



-- port toJsUseToken : String -> Cmd msg


port toJsSignUp : SignUp -> Cmd msg


port toJsSignOut : () -> Cmd msg
