module Investor exposing (subscriptions, view)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Investor.Pages.Home as Home
import Shared exposing (..)
import Shared.Context exposing (Context)
import Shared.Flags as Flags exposing (Flags)
import Shared.Pages.NotFound as NotFound
import Shared.Return as Return
import Shared.Routes as Routes exposing (Route)
import Shared.Sessions as Sessions
import UI.Footer as Footer
import UI.Navigation as Navigation
import Url exposing (Url)


view : Context -> PageInvestor -> List (Html Msg)
view context page =
    [ header_ context
    , currentPage context page
    , Footer.view
    ]


header_ : Context -> Html Msg
header_ context =
    nav [ class "flex p-4 bg-grey-darkest text-white" ]
        [ Navigation.logo
        , div
            [ class "ml-8 flex-grow" ]
            [ navigationLink Routes.routeForAdminHome "Home"
            , navigationLink Routes.routeForAdminInvite "Invite"
            ]
        , div []
            [ text context.flags.tokenData.name
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
        [ inner ]


subscriptions : PageInvestor -> Sub Msg
subscriptions page =
    case page of
        PageInvestor_Home pageModel ->
            Sub.map PageInvestorHomeMsg (Home.subscriptions pageModel)
