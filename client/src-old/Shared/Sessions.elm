port module Shared.Sessions exposing (SignIn, SignUp, asEmailInSignUp, asNameInSignUp, asPasswordInSignUp, newSignIn, newSignUp, toJsSignOut, toJsUseToken)

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


port toJsUseToken : String -> Cmd msg


port toJsSignOut : () -> Cmd msg
