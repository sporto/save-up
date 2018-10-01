module UI.ConfirmButton exposing (Args, State(..), view)

import Html exposing (..)
import Html.Events exposing (onClick)


type alias Args msg =
    { click : msg
    , commit : msg
    , cancel : msg
    }


type State
    = Initial
    | Engaged


view : String -> Args msg -> State -> Html msg
view label args state =
    case state of
        Initial ->
            div []
                [ button [ onClick args.click ]
                    [ text label
                    ]
                ]

        Engaged ->
            div []
                [ button [ onClick args.commit ] [ text "Yes" ]
                , button [ onClick args.cancel ] [ text "Cancel" ]
                ]
