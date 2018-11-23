module UI.Chart exposing (view)

import Color
import DateFormat as DT
import Html exposing (..)
import Html.Attributes exposing (class)
import LineChart as LineChart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis.Line as AxisLine
import LineChart.Axis.Range as Range
import LineChart.Axis.Tick as Tick
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Title as Title
import LineChart.Container as Container
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk exposing (..)
import LineChart.Legends as Legends
import LineChart.Line as Line
import Svg
import Time exposing (Posix)


type alias Transaction =
    { createdAt : Posix
    , balanceInCents : Int
    }


view : List Transaction -> Html msg
view transactions =
    div [ class "flex justify-center" ]
        [ chart transactions
        ]


chart : List Transaction -> Html msg
chart transactions =
    LineChart.viewCustom
        chartConfig
        [ LineChart.line Color.blue Dots.diamond "Transactions" transactions ]


chartConfig : LineChart.Config Transaction msg
chartConfig =
    { y = yAxisConfig
    , x = xAxisConfig
    , container = Container.default "transactions-chart"
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.none
    , events = Events.default
    , junk = Junk.default
    , grid = Grid.default
    , area = Area.normal 0.2
    , line = Line.wider 3
    , dots = Dots.default
    }


yAxisConfig : Axis.Config Transaction msg
yAxisConfig =
    Axis.custom
        { title = Title.default "Balance"
        , variable = getY >> Just
        , pixels = 480
        , range = Range.padded 20 0
        , axisLine = AxisLine.none
        , ticks = Ticks.intCustom 2 tickBalance
        }


xAxisConfig : Axis.Config Transaction msg
xAxisConfig =
    Axis.custom
        { title = Title.default "Date"
        , variable = getX >> Just
        , pixels = 960
        , range = Range.padded 20 0
        , axisLine = AxisLine.none
        , ticks = Ticks.timeCustom Time.utc 4 tickTime
        }


tickBalance : Int -> Tick.Config msg
tickBalance cents =
    let
        label =
            Junk.label Color.black (formatYTick cents)

        config : Tick.Properties msg
        config =
            { position = cents |> toFloat
            , color = Color.black
            , width = 1
            , length = 4
            , grid = False
            , direction = Tick.negative
            , label = Just label
            }
    in
    Tick.custom config


tickTime : Tick.Time -> Tick.Config msg
tickTime time =
    let
        label =
            Junk.label Color.black (formatXTick time.timestamp)

        config : Tick.Properties msg
        config =
            { position = time.timestamp |> Time.posixToMillis |> toFloat
            , color = Color.black
            , width = 1
            , length = 4
            , grid = False
            , direction = Tick.negative
            , label = Just label
            }
    in
    Tick.custom config


getX : Transaction -> Float
getX transaction =
    transaction.createdAt
        |> Time.posixToMillis
        |> toFloat


getY : Transaction -> Float
getY transaction =
    transaction.balanceInCents
        |> toFloat


formatY : Transaction -> String
formatY transaction =
    transaction.balanceInCents
        // 100
        |> String.fromInt


formatXTick : Posix -> String
formatXTick posix =
    DT.format
        [ DT.dayOfMonthNumber
        , DT.text " "
        , DT.monthNameAbbreviated
        , DT.text " "
        , DT.yearNumberLastTwo
        ]
        Time.utc
        posix


formatX : Transaction -> String
formatX transaction =
    formatXTick
        transaction.createdAt


formatYTick : Int -> String
formatYTick cents =
    (cents // 100)
        |> String.fromInt
