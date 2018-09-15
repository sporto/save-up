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
import Shared.Globals exposing (..)
import Shared.Return as Return
import Shared.Routes as Routes exposing (Route)
import Shared.Sessions as Sessions
import Url exposing (Url)


initCurrentPage : PublicContext -> Routes.RouteInPublic -> ( PagePublic, Cmd MsgPublic )
initCurrentPage context route =
    case route of
        Routes.RouteInPublic_SignIn ->
            SignIn.init context.flags
                |> Return.mapBoth
                    PagePublic_SignIn
                    PageSignInMsg

        Routes.RouteInPublic_SignUp ->
            SignUp.init context.flags
                |> Return.mapBoth
                    PagePublic_SignUp
                    PageSignUpMsg

        Routes.RouteInPublic_Invitation token ->
            Invitation.init context.flags token
                |> Return.mapBoth
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


update : PublicContext -> MsgPublic -> PagePublic -> ( PagePublic, Cmd MsgPublic )
update context msg page =
    case msg of
        PageSignInMsg sub ->
            case page of
                PagePublic_SignIn pageModel ->
                    let
                        ( newPageModel, pageCmd ) =
                            SignIn.update
                                context
                                sub
                                pageModel
                    in
                    ( PagePublic_SignIn newPageModel
                    , Cmd.map PageSignInMsg pageCmd
                    )

                _ ->
                    ( page, Cmd.none )

        PageSignUpMsg sub ->
            case page of
                PagePublic_SignUp pageModel ->
                    let
                        ( newPageModel, pageCmd ) =
                            SignUp.update
                                context
                                sub
                                pageModel
                    in
                    ( PagePublic_SignUp newPageModel
                    , Cmd.map PageSignUpMsg pageCmd
                    )

                _ ->
                    ( page, Cmd.none )

        PageInvitationMsg sub ->
            case page of
                PagePublic_Invitation pageModel ->
                    let
                        ( newPageModel, pageCmd ) =
                            Invitation.update
                                context
                                sub
                                pageModel
                    in
                    ( PagePublic_Invitation newPageModel
                    , Cmd.map PageInvitationMsg pageCmd
                    )

                _ ->
                    ( page, Cmd.none )


view : PublicContext -> PagePublic -> List (Html Msg)
view context page =
    [ currentPage context page ]


currentPage : PublicContext -> PagePublic -> Html Msg
currentPage context page =
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
