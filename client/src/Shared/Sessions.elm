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


type alias SignIn =
    { email : String
    , password : String
    }


newSignIn : SignIn
newSignIn =
    { email = ""
    , password = ""
    }



-- port toJsUseToken : String -> Cmd msg


port toJsSignUp : SignUp -> Cmd msg


port toJsSignOut : () -> Cmd msg
