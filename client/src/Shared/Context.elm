module Shared.Context exposing (Context, PublicContext)

import Shared.Flags exposing (Flags, PublicFlags)


type alias PublicContext =
    { flags : PublicFlags
    }


type alias Context =
    { flags : Flags
    }
