module Shared.Globals exposing (Authentication, Context, Flags, PublicContext, Role(..), TokenData)


type alias Flags =
    { apiHost : String
    , token : Maybe String
    }


type alias TokenData =
    { name : String
    , email : String
    , role : Role
    }


type Role
    = Admin
    | Investor


type alias PublicContext =
    { flags : Flags
    }


type alias Context =
    { flags : Flags
    , auth : Authentication
    }


type alias Authentication =
    { token : String
    , data : TokenData
    }
