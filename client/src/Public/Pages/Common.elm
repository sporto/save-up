module Public.Pages.Common exposing (LayoutArgs, layout)

import Html exposing (..)
import Html.Attributes exposing (class)
import Shared.Globals exposing (..)
import UI.PublicLinks as PublicLinks


type alias LayoutArgs msg =
    { containerAttributes : List (Attribute msg)
    }


layout : PublicContext -> LayoutArgs msg -> List (Html msg) -> Html msg
layout context args children =
    div [ class "flex items-center justify-center pt-16" ]
        [ div ([] ++ args.containerAttributes)
            [ div [ class "bg-white sm:shadow-md rounded sm:px-8 py-8 mt-3" ]
                children
            , PublicLinks.view context
            ]
        ]
