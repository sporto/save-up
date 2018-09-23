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
import Notifications
import Public
import Public.Pages.Invitation
import Public.Pages.SignIn
import Public.Pages.SignUp
import Root exposing (..)
import Shared.Actions as Actions exposing (Actions)
import Shared.AppLocation as AppLocation
import Shared.Globals exposing (..)
import Shared.Pages.NotFound as NotFound
import Shared.Return as Return
import Shared.Return3 as R3
import Shared.Routes as Routes
import Shared.Sessions as Sessions
import UI.Footer as Footer
import UI.Navigation as Navigation
import Url exposing (Url)


initialModel : Flags -> Url -> Nav.Key -> Notifications.Model -> Model
initialModel flags url navKey notModel =
    { authentication = authenticate flags.token
    , flags = flags
    , currentLocation = AppLocation.fromUrl url
    , navKey = navKey
    , notifications = notModel
    , page = Page_NotFound
    }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( notModel, notCmd ) =
            Notifications.init

        model =
            initialModel flags url key notModel

        cmd =
            Cmd.map NotificationsMsg notCmd
    in
    ( model
    , cmd
    , Actions.none
    )
        |> R3.andThen initCurrentPage
        |> processActions


initCurrentPage : Model -> ( Model, Cmd Msg, Actions Msg )
initCurrentPage model =
    let
        contextResult =
            authContext model

        currentRoute =
            model.currentLocation.route

        notFound =
            ( Page_NotFound, Cmd.none, Actions.none )

        ( newPage, newCmd, newAction ) =
            case ( contextResult, currentRoute ) of
                ( AuthContext_Admin context, Routes.Route_Admin subRoute ) ->
                    Admin.initCurrentPage
                        context
                        subRoute
                        |> R3.mapAll (Page_Admin context.auth) Msg_Admin

                ( AuthContext_Admin _, Routes.Route_Public Routes.RouteInPublic_SignIn ) ->
                    ( Page_NotFound
                    , Nav.replaceUrl model.navKey (Routes.pathFor Routes.routeForAdminHome)
                    , Actions.none
                    )

                ( AuthContext_Investor context, Routes.Route_Investor subRoute ) ->
                    Investor.initCurrentPage context subRoute
                        |> R3.mapAll (Page_Investor context.auth) Msg_Investor

                ( AuthContext_Investor _, Routes.Route_Public Routes.RouteInPublic_SignIn ) ->
                    ( Page_NotFound
                    , Nav.replaceUrl model.navKey (Routes.pathFor Routes.routeForInvestorHome)
                    , Actions.none
                    )

                ( AuthContext_Public context, Routes.Route_Public subRoute ) ->
                    Public.initCurrentPage context subRoute
                        |> R3.mapAll Page_Public Msg_Public

                ( _, _ ) ->
                    notFound
    in
    ( { model | page = newPage }
    , newCmd
    , newAction
    )


authenticate : Maybe String -> Maybe Authentication
authenticate maybeToken =
    maybeToken
        |> Maybe.andThen Sessions.authenticate


type AuthContext
    = AuthContext_Public PublicContext
    | AuthContext_Admin Context
    | AuthContext_Investor Context


authContext : Model -> AuthContext
authContext model =
    case model.authentication of
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
                (newPublicContext model)


newContext : Model -> Authentication -> Context
newContext model auth =
    { flags = model.flags
    , auth = auth
    , navKey = model.navKey
    }


newPublicContext : Model -> PublicContext
newPublicContext model =
    { flags = model.flags
    , navKey = model.navKey
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updateWithActions msg model
        |> processActions


updateWithActions : Msg -> Model -> ( Model, Cmd Msg, Actions Msg )
updateWithActions msg model =
    case ( msg, model.page ) of
        ( ChangeRoute route, _ ) ->
            ( model, Nav.pushUrl model.navKey (Routes.pathFor route), Actions.none )

        ( SignOut, _ ) ->
            ( model, Cmd.none, Actions.endSession )

        ( NotificationsMsg subMsg, _ ) ->
            let
                ( notifications, cmd ) =
                    Notifications.update subMsg model.notifications
            in
            ( { model | notifications = notifications }
            , Cmd.map NotificationsMsg cmd
            , Actions.none
            )

        ( OnUrlChange url, _ ) ->
            let
                newLocation =
                    AppLocation.fromUrl url
            in
            ( { model | currentLocation = newLocation }
            , Cmd.none
            , Actions.none
            )
                |> R3.andThen initCurrentPage

        ( OnUrlRequest urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navKey (Url.toString url)
                    , Actions.none
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    , Actions.none
                    )

        ( Msg_Admin subMsg, Page_Admin auth page ) ->
            Admin.update
                (newContext model auth)
                subMsg
                page
                |> R3.mapAll (\p -> { model | page = Page_Admin auth p }) Msg_Admin

        ( Msg_Investor subMsg, Page_Investor auth page ) ->
            Investor.update
                (newContext model auth)
                subMsg
                page
                |> R3.mapAll (\p -> { model | page = Page_Investor auth p }) Msg_Investor

        ( Msg_Public subMsg, Page_Public page ) ->
            Public.update
                (newPublicContext model)
                subMsg
                page
                |> R3.mapAll (\p -> { model | page = Page_Public p }) Msg_Public

        _ ->
            ( model, Cmd.none, Actions.none )


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


processActions : ( Model, Cmd Msg, Actions Msg ) -> ( Model, Cmd Msg )
processActions ( model, cmds, actions ) =
    case actions of
        [] ->
            ( model, cmds )

        action :: restActions ->
            ( model, cmds, restActions )
                |> R3.andThen (processAction action)
                |> processActions



-- debugActions : ( Model, Cmd Msg, Actions Msg ) -> ( Model, Cmd Msg, Actions Msg )
-- debugActions ( model, cmds, actions ) =
--     let
--         _ =
--             Debug.log "model" model
--         _ =
--             Debug.log "cmds" cmds
--         _ =
--             Debug.log "actions" actions
--     in
--     ( model, cmds, actions )


{-| An action can return another action
e.g show a notification
-}
processAction : Actions.Action Msg -> Model -> ( Model, Cmd Msg, Actions Msg )
processAction action model =
    case action of
        Actions.Action_StartSession token ->
            Sessions.startSession
                token
                model
                ChangeRoute

        Actions.Action_EndSession ->
            Sessions.endSession
                model
                ChangeRoute

        Actions.Action_AddNotification notification ->
            let
                ( notifications, cmd ) =
                    Notifications.add notification model.notifications
            in
            ( { model | notifications = notifications }
            , Cmd.map NotificationsMsg cmd
            , Actions.none
            )



-- VIEWS


view : Model -> Browser.Document Msg
view model =
    { title = "SaveUp"
    , body = bodyFor model
    }


bodyFor : Model -> List (Html Msg)
bodyFor model =
    let
        page =
            case model.page of
                Page_NotFound ->
                    NotFound.view model.authentication model.currentLocation

                Page_Public pageModel ->
                    Public.view (newPublicContext model) pageModel

                Page_Admin auth pageModel ->
                    Admin.view (newContext model auth) pageModel
                        |> Html.map Msg_Admin

                Page_Investor auth pageModel ->
                    Investor.view (newContext model auth) pageModel
    in
    [ Notifications.view model.notifications
    , page
    ]


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
