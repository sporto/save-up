module Shared.Flags exposing (..)

import Json.Decode as Decode


type alias PublicFlags =
    { apiHost : String
    }


-- publicFlagsDecoder : Decode.Decoder PublicFlags
-- publicFlagsDecoder =
--     Decode.map PublicFlags
--         (Decode.field "apiHost" Decode.string)
