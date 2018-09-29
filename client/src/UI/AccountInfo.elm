module UI.AccountInfo exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href, name, src, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import UI.Icons as Icons


type alias Account a =
    { a
        | balanceInCents : Int
        , yearlyInterest : Float
    }


view : Account a -> Html msg
view account =
    div [ class "flex items-center" ]
        [ balance account
        , interest account
        ]


balance : Account a -> Html msg
balance account =
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


interest : Account a -> Html msg
interest account =
    div []
        [ span [ class "ml-8" ] [ text "Yearly interest" ]
        , span [ class "ml-2 text-2xl font-semibold" ] [ text (String.fromFloat account.yearlyInterest) ]
        , span [ class "ml-1 mr-2" ] [ text "%" ]
        , button [] [ Icons.edit ]
        ]
