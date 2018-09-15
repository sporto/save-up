module Shared.Flags exposing (Flags, TokenData)


type alias Flags =
    { apiHost : String
    , tokenData : Maybe TokenData
    , token : Maybe String
    }


type alias TokenData =
    { name : String
    , email : String
    , role : String
    }
