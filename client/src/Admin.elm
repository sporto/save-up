module Admin exposing (Msg, PageAdmin, initCurrentPage, subscriptions, update, view)

import Admin.Pages.Account as Account
import Admin.Pages.CreateInvestor as CreateInvestor
import Admin.Pages.Home as Home
import Admin.Pages.InviteAdmin as InviteAdmin
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Notifications
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


type PageAdmin
    = PageAdmin_Home Home.Model
    | PageAdmin_Account Account.Model
    | PageAdmin_InviteAdmin InviteAdmin.Model
    | PageAdmin_CreateInvestor CreateInvestor.Model


type Msg
    = PageAdminAccountMsg Account.Msg
    | PageAdminHomeMsg Home.Msg
    | PageAdminInviteAdminMsg InviteAdmin.Msg
    | PageAdminCreateInvestorMsg CreateInvestor.Msg
    | MsgAdmin_SignOut


type alias Returns =
    ( PageAdmin, Cmd Msg, Actions.Actions Msg )


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

        Routes.RouteInAdmin_InviteAdmin ->
            InviteAdmin.init
                |> Return.mapAll PageAdmin_InviteAdmin PageAdminInviteAdminMsg

        Routes.RouteInAdmin_CreateInvestor ->
            CreateInvestor.init
                |> Return.mapAll PageAdmin_CreateInvestor PageAdminCreateInvestorMsg


subscriptions : PageAdmin -> Sub Msg
subscriptions page =
    case page of
        PageAdmin_Home pageModel ->
            Sub.map PageAdminHomeMsg (Home.subscriptions pageModel)

        PageAdmin_Account pageModel ->
            Sub.map PageAdminAccountMsg (Account.subscriptions pageModel)

        PageAdmin_InviteAdmin pageModel ->
            Sub.map PageAdminInviteAdminMsg (InviteAdmin.subscriptions pageModel)

        PageAdmin_CreateInvestor pageModel ->
            Sub.map PageAdminCreateInvestorMsg (CreateInvestor.subscriptions pageModel)


update : Context -> Msg -> PageAdmin -> Returns
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

        PageAdminInviteAdminMsg sub ->
            case page of
                PageAdmin_InviteAdmin pageModel ->
                    InviteAdmin.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll PageAdmin_InviteAdmin PageAdminInviteAdminMsg

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


view : Context -> PageAdmin -> Html Msg
view context adminPage =
    section [ class "flex flex-col h-full" ]
        [ header_ context
        , currentPage context adminPage
        , Footer.view
        ]


header_ : Context -> Html Msg
header_ context =
    nav [ class "flex p-4 bg-grey-darkest text-white flex-no-shrink" ]
        [ Navigation.logo
        , div
            [ class "ml-8 flex-grow" ]
            [ navigationLink Routes.routeForAdminHome "Home"
            , navigationLink Routes.routeForAdminInviteAdmin "Invite admin"
            , navigationLink Routes.routeForAdminCreateInvestor "Create investor"
            ]
        , div []
            [ text context.auth.data.name
            , Navigation.signOut MsgAdmin_SignOut
            ]
        ]


navigationLink : Route -> String -> Html Msg
navigationLink route label =
    a
        [ href (Routes.pathFor route)
        , class "text-white mr-6 no-underline"
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

                PageAdmin_InviteAdmin pageModel ->
                    InviteAdmin.view context pageModel
                        |> map PageAdminInviteAdminMsg

                PageAdmin_CreateInvestor pageModel ->
                    CreateInvestor.view context pageModel
                        |> map PageAdminCreateInvestorMsg
    in
    section [ class "flex-auto" ]
        [ page ]
