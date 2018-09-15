module Admin exposing (subscriptions, view)

import Admin.Pages.Account as Account
import Admin.Pages.Home as Home
import Admin.Pages.Invite as Invite
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
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


view : Context -> PageAdmin -> List (Html Msg)
view context adminPage =
    [ header_ context
    , currentPage context adminPage
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


currentPage : Context -> PageAdmin -> Html Msg
currentPage context adminPage =
    let
        page =
            case adminPage of
                PageAdmin_Home pageModel ->
                    Home.view context pageModel
                        |> map PageAdminHomeMsg

                PageAdmin_Account pageModel ->
                    Account.view context pageModel
                        |> map PageAdminAccountMsg

                PageAdmin_Invite pageModel ->
                    Invite.view context pageModel
                        |> map PageAdminInviteMsg
    in
    section [ class "flex-auto" ]
        [ page ]


subscriptions : PageAdmin -> Sub Msg
subscriptions model =
    case model of
        PageAdmin_Home pageModel ->
            Sub.map PageAdminHomeMsg (Home.subscriptions pageModel)

        PageAdmin_Account pageModel ->
            Sub.map PageAdminAccountMsg (Account.subscriptions pageModel)

        PageAdmin_Invite pageModel ->
            Sub.map PageAdminInviteMsg (Invite.subscriptions pageModel)
