module Shared.Globals exposing (Authentication, Context, Flags, PublicContext, Role(..), TokenData)

import Browser.Navigation as Nav
import Shared.AppLocation exposing (AppLocation)
import Time exposing (Posix)


type alias Flags =
    { apiHost : String
    , token : Maybe String
    }


type Role
    = Admin
    | Investor


type alias PublicContext =
    { flags : Flags
    , navKey : Nav.Key
    , currentLocation : AppLocation
    }


type alias Context =
    { flags : Flags
    , auth : Authentication
    , navKey : Nav.Key
    }


type alias Authentication =
    { token : String
    , data : TokenData
    }


type alias TokenData =
    { exp : Posix
    , userId : Int
    , email : String
    , name : String
    , role : Role
    }
