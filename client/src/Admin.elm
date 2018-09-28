module Admin exposing (Msg, Page, initCurrentPage, subscriptions, update, view)

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


type Page
    = Page_Home Home.Model
    | Page_Account Account.Model
    | Page_InviteAdmin InviteAdmin.Model
    | Page_CreateInvestor CreateInvestor.Model


type Msg
    = Msg_PageAccount Account.Msg
    | Msg_PageHome Home.Msg
    | Msg_PageInviteAdmin InviteAdmin.Msg
    | Msg_PageCreateInvestor CreateInvestor.Msg
    | SignOut


type alias Returns =
    ( Page, Cmd Msg, Actions.Actions Msg )


initCurrentPage : Context -> Routes.RouteInAdmin -> Returns
initCurrentPage context adminRoute =
    case adminRoute of
        Routes.RouteInAdmin_Account id subRoute ->
            Account.init
                context
                id
                subRoute
                |> Return.mapAll Page_Account Msg_PageAccount

        Routes.RouteInAdmin_Home ->
            Home.init
                context
                |> Return.mapAll Page_Home Msg_PageHome

        Routes.RouteInAdmin_InviteAdmin ->
            InviteAdmin.init
                |> Return.mapAll Page_InviteAdmin Msg_PageInviteAdmin

        Routes.RouteInAdmin_CreateInvestor ->
            CreateInvestor.init
                |> Return.mapAll Page_CreateInvestor Msg_PageCreateInvestor


subscriptions : Page -> Sub Msg
subscriptions page =
    case page of
        Page_Home pageModel ->
            Sub.map Msg_PageHome (Home.subscriptions pageModel)

        Page_Account pageModel ->
            Sub.map Msg_PageAccount (Account.subscriptions pageModel)

        Page_InviteAdmin pageModel ->
            Sub.map Msg_PageInviteAdmin (InviteAdmin.subscriptions pageModel)

        Page_CreateInvestor pageModel ->
            Sub.map Msg_PageCreateInvestor (CreateInvestor.subscriptions pageModel)


update : Context -> Msg -> Page -> Returns
update context msg page =
    case msg of
        Msg_PageAccount sub ->
            case page of
                Page_Account pageModel ->
                    Account.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll Page_Account Msg_PageAccount

                _ ->
                    ( page, Cmd.none, Actions.none )

        Msg_PageHome sub ->
            case page of
                Page_Home pageModel ->
                    Home.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll Page_Home Msg_PageHome

                _ ->
                    ( page, Cmd.none, Actions.none )

        Msg_PageInviteAdmin sub ->
            case page of
                Page_InviteAdmin pageModel ->
                    InviteAdmin.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll Page_InviteAdmin Msg_PageInviteAdmin

                _ ->
                    ( page, Cmd.none, Actions.none )

        Msg_PageCreateInvestor sub ->
            case page of
                Page_CreateInvestor pageModel ->
                    CreateInvestor.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll Page_CreateInvestor Msg_PageCreateInvestor

                _ ->
                    ( page, Cmd.none, Actions.none )

        SignOut ->
            ( page, Cmd.none, Actions.endSession )


view : Context -> Page -> Html Msg
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
            , Navigation.signOut SignOut
            ]
        ]


navigationLink : Route -> String -> Html Msg
navigationLink route label =
    a
        [ href (Routes.pathFor route)
        , class "text-white mr-6 no-underline"
        ]
        [ text label ]


currentPage : Context -> Page -> Html Msg
currentPage context adminPage =
    let
        page =
            case adminPage of
                Page_Home pageModel ->
                    Home.view context pageModel
                        |> map Msg_PageHome

                Page_Account pageModel ->
                    Account.view context pageModel
                        |> map Msg_PageAccount

                Page_InviteAdmin pageModel ->
                    InviteAdmin.view context pageModel
                        |> map Msg_PageInviteAdmin

                Page_CreateInvestor pageModel ->
                    CreateInvestor.view context pageModel
                        |> map Msg_PageCreateInvestor
    in
    section [ class "flex-auto" ]
        [ page ]
