module UI.Icons exposing (chart, deposit, money, spinner, withdraw)

import Html exposing (..)
import Html.Attributes exposing (class, href, name, style, type_, value)


spinner =
    li [ class "fas fa-spinner fa-spin fa-lg" ] []


chart =
    li [ class "fas fa-chart-area" ] []


money =
    li [ class "fas fa-money-bill" ] []


deposit =
    li [ class "fas fa-plus" ] []


withdraw =
    li [ class "fas fa-minus" ] []
