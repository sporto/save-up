module UI.ChartV2 exposing (view)

import Axis
import Color
import Path exposing (Path)
import Scale exposing (ContinuousScale)
import Shape
import Time exposing (Posix)
import TypedSvg exposing (g, svg)
import TypedSvg.Attributes exposing (class, fill, stroke, transform, viewBox)
import TypedSvg.Attributes.InPx exposing (strokeWidth)
import TypedSvg.Core exposing (Svg)
import TypedSvg.Types exposing (Fill(..), Transform(..))


type alias Transaction =
    { createdAt : Posix
    , balanceInCents : Int
    }


type alias Point =
    ( Time.Posix, Float )


w : Float
w =
    900


h : Float
h =
    450


padding : Float
padding =
    48


second =
    1000


minute =
    60 * second


hour =
    60 * minute


day =
    24 * hour


week =
    7 * day


xScale : List Point -> ContinuousScale Time.Posix
xScale points =
    let
        first =
            points
                |> List.head
                |> Maybe.map Tuple.first
                |> Maybe.map (movePosix -week)
                |> Maybe.withDefault (Time.millisToPosix 1448928000000)

        last =
            points
                |> List.reverse
                |> List.head
                |> Maybe.map Tuple.first
                |> Maybe.map (movePosix week)
                |> Maybe.withDefault (Time.millisToPosix 1456790400000)
    in
    Scale.time
        Time.utc
        ( 0, w - 2 * padding )
        ( first, last )


movePosix : Int -> Posix -> Posix
movePosix millis posix =
    posix
        |> Time.posixToMillis
        |> (+) millis
        |> Time.millisToPosix


yScale : List Point -> ContinuousScale Float
yScale points =
    let
        max =
            points
                |> List.map Tuple.second
                |> List.maximum
                |> Maybe.withDefault 100
                |> (*) 1.2
    in
    Scale.linear ( h - 2 * padding, 0 ) ( 0, max )


xAxis : List Point -> Svg msg
xAxis points =
    Axis.bottom
        [ Axis.tickCount (List.length points) ]
        (xScale points)


yAxis : List Point -> Svg msg
yAxis points =
    Axis.left [ Axis.tickCount 5 ]
        (yScale points)


transformToLineData :
    List Point
    -> Point
    -> Maybe ( Float, Float )
transformToLineData points ( x, y ) =
    Just
        ( Scale.convert (xScale points) x
        , Scale.convert (yScale points) y
        )


tranfromToAreaData :
    List Point
    -> Point
    -> Maybe ( ( Float, Float ), ( Float, Float ) )
tranfromToAreaData points ( x, y ) =
    Just
        ( ( Scale.convert (xScale points) x, Tuple.first (Scale.rangeExtent (yScale points)) )
        , ( Scale.convert (xScale points) x, Scale.convert (yScale points) y )
        )


line : List Point -> Path
line points =
    List.map (transformToLineData points) points
        |> Shape.line Shape.monotoneInXCurve


area : List Point -> Path
area points =
    List.map (tranfromToAreaData points) points
        |> Shape.area Shape.monotoneInXCurve


view : List Transaction -> Svg msg
view transactions =
    let
        points =
            List.map
                (\t ->
                    ( t.createdAt
                    , toFloat t.balanceInCents / 100
                    )
                )
                transactions
    in
    svg [ viewBox 0 0 w h ]
        [ g [ transform [ Translate (padding - 1) (h - padding) ] ]
            [ xAxis points ]
        , g [ transform [ Translate (padding - 1) padding ] ]
            [ yAxis points ]
        , g [ transform [ Translate padding padding ], class [ "series" ] ]
            [ Path.element (area points) [ strokeWidth 3, fill <| Fill fillColor ]
            , Path.element (line points) [ stroke lineColor, strokeWidth 3, fill FillNone ]
            ]
        ]


fillColor =
    Color.rgba 0.5 0.6 0.8 0.54


lineColor =
    Color.rgb 0.5 0.6 0.8
