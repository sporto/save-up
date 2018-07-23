module Shared.Flags exposing (..)

import Json.Decode as Decode


type alias PublicFlags =
    { apiHost : String
    }


type alias Flags =
    { apiHost : String
    , token : Token
    }


type alias Token =
    { name : String
    , email : String
    , role : String
    }



-- publicFlagsDecoder : Decode.Decoder PublicFlags
-- publicFlagsDecoder =
--     Decode.map PublicFlags
--         (Decode.field "apiHost" Decode.string)
