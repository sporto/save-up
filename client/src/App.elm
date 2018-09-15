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
import Shared exposing (Model, Msg(..), Page(..), PageAdmin(..))
import Shared.AppLocation as AppLocation
import Shared.Context exposing (Context)
import Shared.Flags as Flags exposing (Flags)
import Shared.Pages.NotFound as NotFound
import Shared.Return as Return
import Shared.Routes as Routes
import Shared.Sessions as Sessions
import UI.Footer as Footer
import UI.Navigation as Navigation
import Url exposing (Url)


initialModel : Flags -> Url -> Nav.Key -> Model
initialModel flags url key =
    { flags = flags
    , currentLocation = AppLocation.fromUrl url
    , key = key
    , page = Page_NotFound
    }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        model =
            initialModel flags url key

        context =
            newContext model
    in
    ( model
    , Cmd.none
    )
        |> Return.andThen (initCurrentPage context)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        context =
            newContext model
    in
    case msg of
        SignOut ->
            ( model, Sessions.toJsSignOut () )

        OnUrlChange url ->
            let
                newLocation =
                    AppLocation.fromUrl url
            in
            ( { model | currentLocation = newLocation }
            , Cmd.none
            )
                |> Return.andThen (initCurrentPage context)

        OnUrlRequest urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        PageAdminAccountMsg sub ->
            case model.page of
                Page_Admin (PageAdmin_Account pageModel) ->
                    let
                        ( newPageModel, pageCmd ) =
                            Admin.Pages.Account.update
                                context
                                sub
                                pageModel
                    in
                    ( { model | page = Page_Admin (PageAdmin_Account newPageModel) }
                    , Cmd.map PageAdminAccountMsg pageCmd
                    )

                _ ->
                    ( model, Cmd.none )

        PageAdminHomeMsg sub ->
            case model.page of
                Page_Admin (PageAdmin_Home pageModel) ->
                    let
                        ( newPageModel, pageCmd ) =
                            Admin.Pages.Home.update
                                context
                                sub
                                pageModel
                    in
                    ( { model | page = Page_Admin (PageAdmin_Home newPageModel) }
                    , Cmd.map PageAdminHomeMsg pageCmd
                    )

                _ ->
                    ( model, Cmd.none )

        PageAdminInviteMsg sub ->
            case model.page of
                Page_Admin (PageAdmin_Invite pageModel) ->
                    let
                        ( newPageModel, pageCmd ) =
                            Admin.Pages.Invite.update
                                context
                                sub
                                pageModel
                    in
                    ( { model | page = Page_Admin (PageAdmin_Invite newPageModel) }
                    , Cmd.map PageAdminInviteMsg pageCmd
                    )

                _ ->
                    ( model, Cmd.none )


newContext : Model -> Context
newContext model =
    { flags = model.flags
    }


initCurrentPage : Context -> Model -> ( Model, Cmd Msg )
initCurrentPage context model =
    let
        ( newPage, newCmd ) =
            case model.currentLocation.route of
                Routes.Route_Admin subRoute ->
                    initCurrentAdminPage context subRoute
                        |> Return.mapModel Page_Admin

                Routes.Route_NotFound ->
                    ( Page_NotFound, Cmd.none )
    in
    ( { model | page = newPage }, newCmd )


initCurrentAdminPage : Context -> Routes.RouteInAdmin -> ( PageAdmin, Cmd Msg )
initCurrentAdminPage context adminRoute =
    case adminRoute of
        Routes.RouteInAdmin_Account id subRoute ->
            Admin.Pages.Account.init
                context
                id
                subRoute
                |> Return.mapBoth PageAdmin_Account PageAdminAccountMsg

        Routes.RouteInAdmin_Home ->
            Admin.Pages.Home.init
                context
                |> Return.mapBoth PageAdmin_Home PageAdminHomeMsg

        Routes.RouteInAdmin_Invite ->
            Admin.Pages.Invite.init
                |> Return.mapBoth PageAdmin_Invite PageAdminInviteMsg


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageSub =
            case model.page of
                Page_NotFound ->
                    Sub.none

                Page_Admin adminPage ->
                    Admin.subscriptions adminPage
    in
    Sub.batch [ pageSub ]


view : Model -> Browser.Document Msg
view model =
    { title = "SaveUp"
    , body = bodyFor (contextFor model) model
    }


bodyFor : Context -> Model -> List (Html Msg)
bodyFor context model =
    case model.page of
        Page_NotFound ->
            [ NotFound.view ]

        Page_Admin adminPage ->
            Admin.view context adminPage


contextFor : Model -> Context
contextFor model =
    { flags = model.flags
    }


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
