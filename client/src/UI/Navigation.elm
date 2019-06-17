module UI.Navigation exposing
    ( Link
    , logo
    , signOut
    , view
    )

import Html exposing (..)
import Html.Attributes exposing (class, href, style)
import Html.Events exposing (onClick)
import Shared.Globals exposing (..)


logo =
    div [ class "font-semibold" ]
        [ text "SaveUp" ]


signOut : msg -> Html msg
signOut msg =
    button [ class "text-white ml-3", onClick msg ]
        [ text "Log out"
        , i [ class "fas fa-sign-out-alt ml-2" ] []
        ]


type alias Args msg =
    { links : List Link
    , onSignOut : msg
    }


type alias Link =
    { url : String
    , isCurrent : Bool
    , label : String
    }


view : Context -> Args msg -> Html msg
view context args =
    let
        popupMenuGroup =
            div [ class "md:hidden mr-2" ]
                [ popupMenu
                , popupMenuTrigger
                ]

        popupMenuTrigger =
            div [] [ i [ class "px-2 fas fa-bars" ] [] ]

        popupMenu =
            div [ class "displayOnParentHover relative" ]
                [ div
                    [ class "flex flex-col absolute p-2 bg-gray-800 left-0"
                    , style "top" "20px"
                    ]
                    (args.links |> List.map (navigationLink "px-2 py-2 whitespace-no-wrap"))
                ]

        links =
            div [ class "ml-4 hidden md:block" ]
                (args.links |> List.map (navigationLink ""))
    in
    nav [ class "sm:flex p-4 bg-gray-800 text-white justify-between" ]
        [ div [ class "flex" ]
            [ popupMenuGroup
            , logo
            , links
            ]
        , div []
            [ text context.auth.data.name
            , signOut args.onSignOut
            ]
        ]


navigationLink : String -> Link -> Html msg
navigationLink classes link =
    let
        classCurrent =
            if link.isCurrent then
                "font-extrabold"

            else
                ""
    in
    a
        [ href link.url
        , class "text-white mr-6 no-underline"
        , class classCurrent
        , class classes
        ]
        [ text link.label ]
