module Shared.Context exposing (Context)

import Shared.Flags exposing (Flags, PublicFlags)


type alias Context =
    { flags : Flags
    }
