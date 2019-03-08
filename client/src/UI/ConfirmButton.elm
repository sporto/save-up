module UI.ConfirmButton exposing
    ( Args
    , State(..)
    , view
    )

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Shared.Css exposing (molecules)


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
                [ button
                    [ onClick args.click
                    , class molecules.button.primary
                    ]
                    [ text label
                    ]
                ]

        Engaged ->
            div []
                [ button
                    [ onClick args.commit
                    , class molecules.button.secondary
                    , class "mr-2"
                    ]
                    [ text label ]
                , button
                    [ onClick args.cancel
                    , class molecules.button.secondary
                    ]
                    [ text "Cancel" ]
                ]
