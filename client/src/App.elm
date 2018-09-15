module App exposing (main)

import Admin
import Admin.Pages.Account
import Admin.Pages.Home
import Admin.Pages.Invite
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Investor
import Investor.Pages.Home
import Public
import Public.Pages.Invitation
import Public.Pages.SignIn
import Public.Pages.SignUp
import Root exposing (..)
import Shared.AppLocation as AppLocation
import Shared.Globals exposing (..)
import Shared.Pages.NotFound as NotFound
import Shared.Return as Return
import Shared.Routes as Routes
import Shared.Sessions as Sessions
import UI.Footer as Footer
import UI.Navigation as Navigation
import Url exposing (Url)


initialModel : Flags -> Url -> Nav.Key -> Model
initialModel flags url key =
    { authentication = authenticate flags.token
    , flags = flags
    , currentLocation = AppLocation.fromUrl url
    , key = key
    , page = Page_NotFound
    }


authenticate : Maybe String -> Maybe Authentication
authenticate maybeToken =
    Nothing


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        model =
            initialModel flags url key
    in
    ( model
    , Cmd.none
    )
        |> Return.andThen initCurrentPage


initCurrentPage : Model -> ( Model, Cmd Msg )
initCurrentPage model =
    let
        ( newPage, newCmd ) =
            case model.currentLocation.route of
                Routes.Route_Admin subRoute ->
                    case authContext model of
                        AuthContext_Admin context ->
                            Admin.initCurrentPage
                                context
                                subRoute
                                |> Return.mapBoth (Page_Admin context.auth) Msg_Admin

                        _ ->
                            ( Page_NotFound, Cmd.none )

                Routes.Route_Investor subRoute ->
                    case authContext model of
                        AuthContext_Investor context ->
                            Investor.initCurrentPage context subRoute
                                |> Return.mapBoth (Page_Investor context.auth) Msg_Investor

                        _ ->
                            ( Page_NotFound, Cmd.none )

                Routes.Route_Public subRoute ->
                    case authContext model of
                        AuthContext_Public context ->
                            Public.initCurrentPage context subRoute
                                |> Return.mapBoth Page_Public Msg_Public

                        _ ->
                            ( Page_NotFound, Cmd.none )

                Routes.Route_NotFound ->
                    ( Page_NotFound, Cmd.none )
    in
    ( { model | page = newPage }, newCmd )


type AuthContext
    = AuthContext_Public PublicContext
    | AuthContext_Admin Context
    | AuthContext_Investor Context


authContext : Model -> AuthContext
authContext model =
    case authenticate model.flags.token of
        Just authentication ->
            let
                context =
                    newContext model authentication
            in
            case authentication.data.role of
                Admin ->
                    AuthContext_Admin context

                Investor ->
                    AuthContext_Investor context

        Nothing ->
            AuthContext_Public
                { flags = model.flags
                }


newContext : Model -> Authentication -> Context
newContext model auth =
    { flags = model.flags
    , auth = auth
    }


newPublicContext : Model -> PublicContext
newPublicContext model =
    { flags = model.flags
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( SignOut, _ ) ->
            ( model, Sessions.toJsSignOut () )

        ( OnUrlChange url, _ ) ->
            let
                newLocation =
                    AppLocation.fromUrl url
            in
            ( { model | currentLocation = newLocation }
            , Cmd.none
            )
                |> Return.andThen initCurrentPage

        ( OnUrlRequest urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        ( Msg_Admin subMsg, Page_Admin auth page ) ->
            Admin.update
                (newContext model auth)
                subMsg
                page
                |> Return.mapBoth (\p -> { model | page = Page_Admin auth p }) Msg_Admin

        ( Msg_Investor subMsg, Page_Investor auth page ) ->
            Investor.update
                (newContext model auth)
                subMsg
                page
                |> Return.mapBoth (\p -> { model | page = Page_Investor auth p }) Msg_Investor

        ( Msg_Public subMsg, Page_Public page ) ->
            Public.update
                (newPublicContext model)
                subMsg
                page
                |> Return.mapBoth (\p -> { model | page = Page_Public p }) Msg_Public

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageSub =
            case model.page of
                Page_NotFound ->
                    Sub.none

                Page_Admin _ adminPage ->
                    Admin.subscriptions adminPage
                        |> Sub.map Msg_Admin

                Page_Investor _ page ->
                    Investor.subscriptions page
                        |> Sub.map Msg_Investor

                Page_Public page ->
                    Public.subscriptions page
                        |> Sub.map Msg_Public
    in
    Sub.batch [ pageSub ]


view : Model -> Browser.Document Msg
view model =
    { title = "SaveUp"
    , body = bodyFor model
    }


bodyFor : Model -> List (Html Msg)
bodyFor model =
    case model.page of
        Page_NotFound ->
            [ NotFound.view ]

        Page_Public page ->
            Public.view (newPublicContext model) page

        Page_Admin auth page ->
            Admin.view (newContext model auth) page

        Page_Investor auth page ->
            Investor.view (newContext model auth) page


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        , onUrlRequest = OnUrlRequest
        , onUrlChange = OnUrlChange
        }
