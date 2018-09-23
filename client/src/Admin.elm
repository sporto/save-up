module Admin exposing (initCurrentPage, subscriptions, update, view)

import Admin.Pages.Account as Account
import Admin.Pages.CreateInvestor as CreateInvestor
import Admin.Pages.Home as Home
import Admin.Pages.Invite as Invite
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Notifications
import Root exposing (..)
import Shared.Actions as Actions
import Shared.Css as Css
import Shared.Globals exposing (..)
import Shared.Pages.NotFound as NotFound
import Shared.Return3 as Return
import Shared.Routes as Routes exposing (Route)
import Shared.Sessions as Sessions
import UI.Footer as Footer
import UI.Navigation as Navigation
import Url exposing (Url)


type alias Returns =
    ( PageAdmin, Cmd MsgAdmin, Actions.Actions MsgAdmin )


initCurrentPage : Context -> Routes.RouteInAdmin -> Returns
initCurrentPage context adminRoute =
    case adminRoute of
        Routes.RouteInAdmin_Account id subRoute ->
            Account.init
                context
                id
                subRoute
                |> Return.mapAll PageAdmin_Account PageAdminAccountMsg

        Routes.RouteInAdmin_Home ->
            Home.init
                context
                |> Return.mapAll PageAdmin_Home PageAdminHomeMsg

        Routes.RouteInAdmin_Invite ->
            Invite.init
                |> Return.mapAll PageAdmin_Invite PageAdminInviteMsg

        Routes.RouteInAdmin_CreateInvestor ->
            CreateInvestor.init
                |> Return.mapAll PageAdmin_CreateInvestor PageAdminCreateInvestorMsg


subscriptions : PageAdmin -> Sub MsgAdmin
subscriptions page =
    case page of
        PageAdmin_Home pageModel ->
            Sub.map PageAdminHomeMsg (Home.subscriptions pageModel)

        PageAdmin_Account pageModel ->
            Sub.map PageAdminAccountMsg (Account.subscriptions pageModel)

        PageAdmin_Invite pageModel ->
            Sub.map PageAdminInviteMsg (Invite.subscriptions pageModel)

        PageAdmin_CreateInvestor pageModel ->
            Sub.map PageAdminCreateInvestorMsg (CreateInvestor.subscriptions pageModel)


update : Context -> MsgAdmin -> PageAdmin -> Returns
update context msg page =
    case msg of
        PageAdminAccountMsg sub ->
            case page of
                PageAdmin_Account pageModel ->
                    Account.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll PageAdmin_Account PageAdminAccountMsg

                _ ->
                    ( page, Cmd.none, Actions.none )

        PageAdminHomeMsg sub ->
            case page of
                PageAdmin_Home pageModel ->
                    Home.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll PageAdmin_Home PageAdminHomeMsg

                _ ->
                    ( page, Cmd.none, Actions.none )

        PageAdminInviteMsg sub ->
            case page of
                PageAdmin_Invite pageModel ->
                    Invite.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll PageAdmin_Invite PageAdminInviteMsg

                _ ->
                    ( page, Cmd.none, Actions.none )

        PageAdminCreateInvestorMsg sub ->
            case page of
                PageAdmin_CreateInvestor pageModel ->
                    CreateInvestor.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll PageAdmin_CreateInvestor PageAdminCreateInvestorMsg

                _ ->
                    ( page, Cmd.none, Actions.none )

        MsgAdmin_SignOut ->
            ( page, Cmd.none, Actions.endSession )


view : Context -> PageAdmin -> Html MsgAdmin
view context adminPage =
    section [ class "flex flex-col h-full" ]
        [ header_ context
        , currentPage context adminPage
        , Footer.view
        ]


header_ : Context -> Html MsgAdmin
header_ context =
    nav [ class "flex p-4 bg-grey-darkest text-white flex-no-shrink" ]
        [ Navigation.logo
        , div
            [ class "ml-8 flex-grow" ]
            [ navigationLink Routes.routeForAdminHome "Home"
            , navigationLink Routes.routeForAdminInvite "Invite"
            , navigationLink Routes.routeForAdminCreateInvestor "Create investor"
            ]
        , div []
            [ text context.auth.data.name
            , Navigation.signOut MsgAdmin_SignOut
            ]
        ]


navigationLink : Route -> String -> Html MsgAdmin
navigationLink route label =
    a
        [ href (Routes.pathFor route)
        , class "text-white mr-6 no-underline"
        ]
        [ text label ]


currentPage : Context -> PageAdmin -> Html MsgAdmin
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

                PageAdmin_CreateInvestor pageModel ->
                    CreateInvestor.view context pageModel
                        |> map PageAdminCreateInvestorMsg
    in
    section [ class "flex-auto" ]
        [ page ]
