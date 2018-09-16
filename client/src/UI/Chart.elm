module UI.Chart exposing (view)

import Html exposing (..)
import Sparkline
import Time exposing (Posix)


type alias Transaction =
    { createdAt : Posix
    , balanceInCents : Int
    }


view : List Transaction -> Html msg
view transactions =
    chart transactions


chart transactions =
    Sparkline.sparkline { width = 600, height = 300, marginLR = 0, marginTB = 0 }
        [ Sparkline.Line (dataFor transactions)
        ]


dataFor : List Transaction -> Sparkline.DataSet
dataFor transactions =
    transactions
        |> List.map transactionToPoint


transactionToPoint : Transaction -> Sparkline.Point
transactionToPoint transaction =
    ( Time.posixToMillis transaction.createdAt |> toFloat
    , transaction.balanceInCents |> toFloat
    )
