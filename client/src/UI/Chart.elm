module UI.Chart exposing (view)

import Color
import Html exposing (..)
import Html.Attributes exposing (class)
import LineChart as LineChart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Container as Container
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk exposing (..)
import LineChart.Legends as Legends
import LineChart.Line as Line
import Time exposing (Posix)


type alias Transaction =
    { createdAt : Posix
    , balanceInCents : Int
    }


view : List Transaction -> Html msg
view transactions =
    chart transactions


chart : List Transaction -> Html msg
chart transactions =
    LineChart.viewCustom
        config
        [ LineChart.line Color.blue Dots.diamond "Transactions" transactions ]


config : LineChart.Config Transaction msg
config =
    { y = Axis.default 450 "Balance" getY
    , x = Axis.default 700 "Date" getX
    , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.default
    , junk = Junk.default
    , grid = Grid.default
    , area = Area.default
    , line = Line.wider 2
    , dots = Dots.default
    }


getX : Transaction -> Float
getX transaction =
    transaction.createdAt
        |> Time.posixToMillis
        |> toFloat


getY : Transaction -> Float
getY transaction =
    transaction.balanceInCents
        |> toFloat
