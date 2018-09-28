module UI.Icons exposing (chart, deposit, edit, money, spinner, withdraw)

import Html exposing (..)
import Html.Attributes exposing (class, href, name, style, type_, value)


chart =
    li [ class "fas fa-chart-area" ] []


deposit =
    li [ class "fas fa-plus" ] []


edit =
    li [ class "fas fa-edit" ] []


money =
    li [ class "fas fa-money-bill" ] []


spinner =
    li [ class "fas fa-spinner fa-spin fa-lg" ] []


withdraw =
    li [ class "fas fa-minus" ] []
