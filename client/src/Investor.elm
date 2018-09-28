module Investor exposing (Msg, Page, initCurrentPage, subscriptions, update, view)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Investor.Pages.Home as Home
import Shared.Actions as Actions
import Shared.Globals exposing (..)
import Shared.Pages.NotFound as NotFound
import Shared.Return3 as Return
import Shared.Routes as Routes exposing (Route)
import Shared.Sessions as Sessions
import UI.Footer as Footer
import UI.Navigation as Navigation
import Url exposing (Url)


type Page
    = Page_Home Home.Model


type Msg
    = PageHomeMsg Home.Msg
    | SignOut


type alias Returns =
    ( Page, Cmd Msg, Actions.Actions Msg )


initCurrentPage : Context -> Routes.RouteInInvestor -> Returns
initCurrentPage context route =
    case route of
        Routes.RouteInInvestor_Home ->
            Home.init
                context
                |> Return.mapAll Page_Home PageHomeMsg


subscriptions : Page -> Sub Msg
subscriptions page =
    case page of
        Page_Home pageModel ->
            Sub.map PageHomeMsg (Home.subscriptions pageModel)


update : Context -> Msg -> Page -> Returns
update context msg page =
    case msg of
        PageHomeMsg sub ->
            case page of
                Page_Home pageModel ->
                    Home.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll Page_Home PageHomeMsg

        SignOut ->
            ( page, Cmd.none, Actions.endSession )


view : Context -> Page -> Html Msg
view context page =
    section []
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
            [ navigationLink Routes.routeForInvestorHome "Home"
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


currentPage : Context -> Page -> Html Msg
currentPage context page =
    let
        inner =
            case page of
                Page_Home pageModel ->
                    Home.view context pageModel
                        |> map PageHomeMsg
    in
    section [ class "flex-auto" ]
        [ inner ]
