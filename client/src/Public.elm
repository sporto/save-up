module Public exposing (Msg, Page, initCurrentPage, subscriptions, update, view)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Public.Pages.RedeemInvitation as RedeemInvitation
import Public.Pages.RequestPassword as RequestPassword
import Public.Pages.ResetPassword as ResetPassword
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
    | Page_RequestPasswordReset RequestPassword.Model
    | Page_ResetPassword ResetPassword.Model


type Msg
    = Msg_RedeemInvitation RedeemInvitation.Msg
    | Msg_SignIn SignIn.Msg
    | Msg_SignUp SignUp.Msg
    | Msg_RequestPassword RequestPassword.Msg
    | Msg_ResetPassword ResetPassword.Msg


type alias Returns =
    ( Page, Cmd Msg, Actions.Actions Msg )


initCurrentPage : PublicContext -> Routes.RouteInPublic -> Returns
initCurrentPage context route =
    case route of
        Routes.RouteInPublic_SignIn ->
            SignIn.init context
                |> Return.mapAll
                    Page_SignIn
                    Msg_SignIn

        Routes.RouteInPublic_SignUp ->
            SignUp.init context
                |> Return.mapAll
                    Page_SignUp
                    Msg_SignUp

        Routes.RouteInPublic_Invitation token ->
            RedeemInvitation.init context token
                |> Return.mapAll
                    Page_RedeemInvitation
                    Msg_RedeemInvitation

        Routes.RouteInPublic_RequestPasswordReset ->
            RequestPassword.init context
                |> Return.mapAll
                    Page_RequestPasswordReset
                    Msg_RequestPassword

        Routes.RouteInPublic_ResetPassword token ->
            ResetPassword.init context token
                |> Return.mapAll
                    Page_ResetPassword
                    Msg_ResetPassword


subscriptions : Page -> Sub Msg
subscriptions page =
    case page of
        Page_SignIn pageModel ->
            Sub.map Msg_SignIn (SignIn.subscriptions pageModel)

        Page_SignUp pageModel ->
            Sub.map Msg_SignUp (SignUp.subscriptions pageModel)

        Page_RedeemInvitation pageModel ->
            Sub.map Msg_RedeemInvitation (RedeemInvitation.subscriptions pageModel)

        Page_RequestPasswordReset pageModel ->
            Sub.map Msg_RequestPassword (RequestPassword.subscriptions pageModel)

        Page_ResetPassword pageModel ->
            Sub.map Msg_ResetPassword (ResetPassword.subscriptions pageModel)


update : PublicContext -> Msg -> Page -> Returns
update context msg page =
    case msg of
        Msg_SignIn sub ->
            case page of
                Page_SignIn pageModel ->
                    SignIn.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll Page_SignIn Msg_SignIn

                _ ->
                    ( page, Cmd.none, Actions.none )

        Msg_SignUp sub ->
            case page of
                Page_SignUp pageModel ->
                    SignUp.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll Page_SignUp Msg_SignUp

                _ ->
                    ( page, Cmd.none, Actions.none )

        Msg_RedeemInvitation sub ->
            case page of
                Page_RedeemInvitation pageModel ->
                    RedeemInvitation.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll Page_RedeemInvitation Msg_RedeemInvitation

                _ ->
                    ( page, Cmd.none, Actions.none )

        Msg_RequestPassword sub ->
            case page of
                Page_RequestPasswordReset pageModel ->
                    RequestPassword.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll Page_RequestPasswordReset Msg_RequestPassword

                _ ->
                    ( page, Cmd.none, Actions.none )

        Msg_ResetPassword sub ->
            case page of
                Page_ResetPassword pageModel ->
                    ResetPassword.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll Page_ResetPassword Msg_ResetPassword

                _ ->
                    ( page, Cmd.none, Actions.none )


view : PublicContext -> Page -> Html Msg
view context page =
    let
        inner =
            case page of
                Page_SignIn pageModel ->
                    SignIn.view context pageModel
                        |> map Msg_SignIn

                Page_SignUp pageModel ->
                    SignUp.view context pageModel
                        |> map Msg_SignUp

                Page_RedeemInvitation pageModel ->
                    RedeemInvitation.view context pageModel
                        |> map Msg_RedeemInvitation

                Page_RequestPasswordReset pageModel ->
                    RequestPassword.view context pageModel
                        |> map Msg_RequestPassword

                Page_ResetPassword pageModel ->
                    ResetPassword.view context pageModel
                        |> map Msg_ResetPassword
    in
    section [ class "p-4" ]
        [ inner ]
