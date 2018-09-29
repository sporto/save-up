module UI.AccountInfo exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href, name, src, style, type_, value)
import Html.Events exposing (onClick)
import UI.Icons as Icons


type alias Account a =
    { a
        | balanceInCents : Int
        , yearlyInterest : Float
    }


type alias Args msg =
    { canAdmin : Bool
    , onEdit : msg
    }


type alias RateInputField msg =
    Html msg


view : Args msg -> Account a -> Maybe (RateInputField msg) -> Html msg
view args account maybeEditInterestInput =
    div [ class "flex items-center" ]
        [ balance args account
        , interest args account maybeEditInterestInput
        ]


balance : Args msg -> Account a -> Html msg
balance args account =
    let
        accountBalance =
            (account.balanceInCents // 100)
                |> String.fromInt
    in
    div []
        [ text "Balance: "
        , span [ class "text-3xl font-semibold" ] [ text accountBalance ]
        , span [ class "ml-2" ] [ Icons.money ]
        ]


interest : Args msg -> Account a -> Maybe (RateInputField msg) -> Html msg
interest args account maybeEditInterestInput =
    div [ class "flex items-center" ]
        [ span [ class "ml-8" ] [ text "Yearly interest" ]
        , interestInput args account maybeEditInterestInput
        ]


interestInput : Args msg -> Account a -> Maybe (RateInputField msg) -> Html msg
interestInput args account maybeEditInterestInput =
    let
        per =
            span [ class "ml-1 mr-2" ] [ text "%" ]

        inner =
            case maybeEditInterestInput of
                Just input ->
                    [ input
                    , per
                    ]

                Nothing ->
                    [ span [ class "ml-2 text-2xl font-semibold" ] [ text (String.fromFloat account.yearlyInterest) ]
                    , per
                    , interestEditButton args account
                    ]
    in
    div [ class "flex items-center" ] inner


interestEditButton : Args msg -> Account a -> Html msg
interestEditButton args account =
    if args.canAdmin then
        button [ onClick args.onEdit ] [ Icons.edit ]

    else
        text ""
