module Investor exposing (initCurrentPage, subscriptions, update, view)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Investor.Pages.Home as Home
import Root exposing (..)
import Shared.Actions as Actions
import Shared.Globals exposing (..)
import Shared.Pages.NotFound as NotFound
import Shared.Return3 as Return
import Shared.Routes as Routes exposing (Route)
import Shared.Sessions as Sessions
import UI.Footer as Footer
import UI.Navigation as Navigation
import Url exposing (Url)


type alias Returns =
    ( PageInvestor, Cmd MsgInvestor, Actions.Actions MsgInvestor )


initCurrentPage : Context -> Routes.RouteInInvestor -> Returns
initCurrentPage context route =
    case route of
        Routes.RouteInInvestor_Home ->
            Home.init
                context
                |> Return.mapAll PageInvestor_Home PageInvestorHomeMsg


subscriptions : PageInvestor -> Sub MsgInvestor
subscriptions page =
    case page of
        PageInvestor_Home pageModel ->
            Sub.map PageInvestorHomeMsg (Home.subscriptions pageModel)


update : Context -> MsgInvestor -> PageInvestor -> Returns
update context msg page =
    case msg of
        PageInvestorHomeMsg sub ->
            case page of
                PageInvestor_Home pageModel ->
                    Home.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll PageInvestor_Home PageInvestorHomeMsg


view : Context -> PageInvestor -> List (Html Msg)
view context page =
    [ header_ context
    , currentPage context page
    , Footer.view
    ]


header_ : Context -> Html Msg
header_ context =
    nav [ class "flex p-4 bg-grey-darkest text-white flex-no-shrink" ]
        [ Navigation.logo
        , div
            [ class "ml-8 flex-grow" ]
            [ navigationLink Routes.routeForAdminHome "Home"
            ]
        , div []
            [ text context.auth.data.name
            , Navigation.signOut SignOut
            ]
        ]


navigationLink : Route -> String -> Html Msg
navigationLink route label =
    a
        [ href (Routes.pathFor route)
        , class "text-white mr-4 no-underline"
        ]
        [ text label ]


currentPage : Context -> PageInvestor -> Html Msg
currentPage context page =
    let
        inner =
            case page of
                PageInvestor_Home pageModel ->
                    Home.view context pageModel
                        |> map PageInvestorHomeMsg
    in
    section [ class "flex-auto" ]
        [ inner |> map Msg_Investor ]
