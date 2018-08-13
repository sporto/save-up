module Shared.Flags exposing (..)


type alias PublicFlags =
    { apiHost : String
    }


type alias Flags =
    { apiHost : String
    , tokenData : TokenData
    , token : String
    }


type alias TokenData =
    { name : String
    , email : String
    , role : String
    }
