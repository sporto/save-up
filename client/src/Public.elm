module Public exposing (Msg, Page, initCurrentPage, subscriptions, update, view)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Public.Pages.RedeemInvitation as RedeemInvitation
import Public.Pages.RequestPassword as RequestPassword
import Public.Pages.SignIn as SignIn
import Public.Pages.SignUp as SignUp
import Shared.Actions as Actions
import Shared.Globals exposing (..)
import Shared.Return3 as Return
import Shared.Routes as Routes exposing (Route)
import Shared.Sessions as Sessions
import Url exposing (Url)


type Page
    = Page_RedeemInvitation RedeemInvitation.Model
    | Page_SignIn SignIn.Model
    | Page_SignUp SignUp.Model
    | Page_RequestPassword RequestPassword.Model


type Msg
    = PageRedeemInvitationMsg RedeemInvitation.Msg
    | PageSignInMsg SignIn.Msg
    | PageSignUpMsg SignUp.Msg
    | PageRequestPasswordMsg RequestPassword.Msg


type alias Returns =
    ( Page, Cmd Msg, Actions.Actions Msg )


initCurrentPage : PublicContext -> Routes.RouteInPublic -> Returns
initCurrentPage context route =
    case route of
        Routes.RouteInPublic_SignIn ->
            SignIn.init context.flags
                |> Return.mapAll
                    Page_SignIn
                    PageSignInMsg

        Routes.RouteInPublic_SignUp ->
            SignUp.init context.flags
                |> Return.mapAll
                    Page_SignUp
                    PageSignUpMsg

        Routes.RouteInPublic_Invitation token ->
            RedeemInvitation.init context.flags token
                |> Return.mapAll
                    Page_RedeemInvitation
                    PageRedeemInvitationMsg

        Routes.RouteInPublic_RequestPasswordReset ->
            RequestPassword.init context.flags
                |> Return.mapAll
                    Page_RequestPassword
                    PageRequestPasswordMsg


subscriptions : Page -> Sub Msg
subscriptions page =
    case page of
        Page_SignIn pageModel ->
            Sub.map PageSignInMsg (SignIn.subscriptions pageModel)

        Page_SignUp pageModel ->
            Sub.map PageSignUpMsg (SignUp.subscriptions pageModel)

        Page_RedeemInvitation pageModel ->
            Sub.map PageRedeemInvitationMsg (RedeemInvitation.subscriptions pageModel)

        Page_RequestPassword pageModel ->
            Sub.map PageRequestPasswordMsg (RequestPassword.subscriptions pageModel)


update : PublicContext -> Msg -> Page -> Returns
update context msg page =
    case msg of
        PageSignInMsg sub ->
            case page of
                Page_SignIn pageModel ->
                    SignIn.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll Page_SignIn PageSignInMsg

                _ ->
                    ( page, Cmd.none, Actions.none )

        PageSignUpMsg sub ->
            case page of
                Page_SignUp pageModel ->
                    SignUp.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll Page_SignUp PageSignUpMsg

                _ ->
                    ( page, Cmd.none, Actions.none )

        PageRedeemInvitationMsg sub ->
            case page of
                Page_RedeemInvitation pageModel ->
                    RedeemInvitation.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll Page_RedeemInvitation PageRedeemInvitationMsg

                _ ->
                    ( page, Cmd.none, Actions.none )

        PageRequestPasswordMsg sub ->
            case page of
                Page_RequestPassword pageModel ->
                    RequestPassword.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll Page_RequestPassword PageRequestPasswordMsg

                _ ->
                    ( page, Cmd.none, Actions.none )


view : PublicContext -> Page -> Html Msg
view context page =
    let
        inner =
            case page of
                Page_SignIn pageModel ->
                    SignIn.view context pageModel
                        |> map PageSignInMsg

                Page_SignUp pageModel ->
                    SignUp.view context pageModel
                        |> map PageSignUpMsg

                Page_RedeemInvitation pageModel ->
                    RedeemInvitation.view context pageModel
                        |> map PageRedeemInvitationMsg

                Page_RequestPassword pageModel ->
                    RequestPassword.view context pageModel
                        |> map PageRequestPasswordMsg
    in
    section [ class "p-4" ]
        [ inner ]
