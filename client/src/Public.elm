module Public exposing (initCurrentPage, subscriptions, update, view)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Public.Pages.Invitation as Invitation
import Public.Pages.SignIn as SignIn
import Public.Pages.SignUp as SignUp
import Root exposing (..)
import Shared.Actions as Actions
import Shared.Globals exposing (..)
import Shared.Return3 as Return
import Shared.Routes as Routes exposing (Route)
import Shared.Sessions as Sessions
import Url exposing (Url)


type alias Returns =
    ( PagePublic, Cmd MsgPublic, Actions.Actions MsgPublic )


initCurrentPage : PublicContext -> Routes.RouteInPublic -> Returns
initCurrentPage context route =
    case route of
        Routes.RouteInPublic_SignIn ->
            SignIn.init context.flags
                |> Return.mapAll
                    PagePublic_SignIn
                    PageSignInMsg

        Routes.RouteInPublic_SignUp ->
            SignUp.init context.flags
                |> Return.mapAll
                    PagePublic_SignUp
                    PageSignUpMsg

        Routes.RouteInPublic_Invitation token ->
            Invitation.init context.flags token
                |> Return.mapAll
                    PagePublic_Invitation
                    PageInvitationMsg


subscriptions : PagePublic -> Sub MsgPublic
subscriptions page =
    case page of
        PagePublic_SignIn pageModel ->
            Sub.map PageSignInMsg (SignIn.subscriptions pageModel)

        PagePublic_SignUp pageModel ->
            Sub.map PageSignUpMsg (SignUp.subscriptions pageModel)

        PagePublic_Invitation pageModel ->
            Sub.map PageInvitationMsg (Invitation.subscriptions pageModel)


update : PublicContext -> MsgPublic -> PagePublic -> Returns
update context msg page =
    case msg of
        PageSignInMsg sub ->
            case page of
                PagePublic_SignIn pageModel ->
                    SignIn.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll PagePublic_SignIn PageSignInMsg

                _ ->
                    ( page, Cmd.none, Actions.none )

        PageSignUpMsg sub ->
            case page of
                PagePublic_SignUp pageModel ->
                    SignUp.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll PagePublic_SignUp PageSignUpMsg

                _ ->
                    ( page, Cmd.none, Actions.none )

        PageInvitationMsg sub ->
            case page of
                PagePublic_Invitation pageModel ->
                    Invitation.update
                        context
                        sub
                        pageModel
                        |> Return.mapAll PagePublic_Invitation PageInvitationMsg

                _ ->
                    ( page, Cmd.none, Actions.none )


view : PublicContext -> PagePublic -> Html Msg
view context page =
    let
        inner =
            case page of
                PagePublic_SignIn pageModel ->
                    SignIn.view context pageModel
                        |> map PageSignInMsg

                PagePublic_SignUp pageModel ->
                    SignUp.view context pageModel
                        |> map PageSignUpMsg

                PagePublic_Invitation pageModel ->
                    Invitation.view context pageModel
                        |> map PageInvitationMsg
    in
    section [ class "p-4" ]
        [ inner |> map Msg_Public ]
