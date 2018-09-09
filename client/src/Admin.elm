module Admin exposing (main)

import Admin.AppLocation as AppLocation exposing (AppLocation)
import Admin.Pages.Account as Account
import Admin.Pages.Home as Home
import Admin.Pages.Invite as Invite
import Admin.Routes as Routes exposing (Route)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Shared.Context exposing (Context)
import Shared.Flags as Flags exposing (Flags)
import Shared.Pages.NotFound as NotFound
import Shared.Sessions as Sessions
import UI.Footer as Footer
import UI.Navigation as Navigation
import Url exposing (Url)


type alias Model =
    { flags : Flags
    , currentLocation : AppLocation
    , key : Nav.Key
    , page : Page
    }


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
        |> initCurrentPage context


type Msg
    = SignOut
    | OnUrlChange Url
    | OnUrlRequest UrlRequest
    | PageAccountMsg Account.Msg
    | PageHomeMsg Home.Msg
    | PageInviteMsg Invite.Msg


type Page
    = Page_Home Home.Model
    | Page_Account Account.Model
    | Page_Invite Invite.Model
    | Page_NotFound


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
                |> initCurrentPage context

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

        PageAccountMsg sub ->
            case model.page of
                Page_Account pageModel ->
                    let
                        ( newPageModel, pageCmd ) =
                            Account.update
                                context
                                sub
                                pageModel
                    in
                    ( { model | page = Page_Account newPageModel }
                    , Cmd.map PageAccountMsg pageCmd
                    )

                _ ->
                    ( model, Cmd.none )

        PageHomeMsg sub ->
            case model.page of
                Page_Home pageModel ->
                    let
                        ( newPageModel, pageCmd ) =
                            Home.update
                                context
                                sub
                                pageModel
                    in
                    ( { model | page = Page_Home newPageModel }
                    , Cmd.map PageHomeMsg pageCmd
                    )

                _ ->
                    ( model, Cmd.none )

        PageInviteMsg sub ->
            case model.page of
                Page_Invite pageModel ->
                    let
                        ( newPageModel, pageCmd ) =
                            Invite.update
                                context
                                sub
                                pageModel
                    in
                    ( { model | page = Page_Invite newPageModel }
                    , Cmd.map PageInviteMsg pageCmd
                    )

                _ ->
                    ( model, Cmd.none )


newContext : Model -> Context
newContext model =
    { flags = model.flags
    }


initCurrentPage : Context -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage context ( model, cmds ) =
    let
        ( newPage, newCmd ) =
            case model.currentLocation.route of
                Routes.Route_Account id subRoute ->
                    let
                        ( pageModel, pageCmd ) =
                            Account.init
                                context
                                id
                                subRoute
                    in
                    ( Page_Account pageModel, Cmd.map PageAccountMsg pageCmd )

                Routes.Route_Home ->
                    let
                        ( pageModel, pageCmd ) =
                            Home.init
                                context
                    in
                    ( Page_Home pageModel, Cmd.map PageHomeMsg pageCmd )

                Routes.Route_Invite ->
                    let
                        ( pageModel, pageCmd ) =
                            Invite.init
                    in
                    ( Page_Invite pageModel, Cmd.map PageInviteMsg pageCmd )

                Routes.Route_NotFound ->
                    ( Page_NotFound, Cmd.none )
    in
    ( { model | page = newPage }, Cmd.batch [ cmds, newCmd ] )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageSub =
            case model.page of
                Page_NotFound ->
                    Sub.none

                Page_Account pageModel ->
                    Sub.map PageAccountMsg (Account.subscriptions pageModel)

                Page_Home pageModel ->
                    Sub.map PageHomeMsg (Home.subscriptions pageModel)

                Page_Invite pageModel ->
                    Sub.map PageInviteMsg (Invite.subscriptions pageModel)
    in
    Sub.batch
        [ pageSub
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "SaveUp"
    , body =
        [ header_ model
        , currentPage model
        , Footer.view
        ]
    }


header_ : Model -> Html Msg
header_ model =
    nav [ class "flex p-4 bg-teal-darker text-white" ]
        [ Navigation.logo
        , div
            [ class "ml-8 flex-grow" ]
            [ navigationLink Routes.Route_Home "Home"
            , navigationLink Routes.Route_Invite "Invite"
            ]
        , div []
            [ text model.flags.tokenData.name
            , Navigation.signOut SignOut
            ]
        ]


navigationLink : Route -> String -> Html Msg
navigationLink route label =
    a
        [ href (Routes.pathFor route)
        , class "text-white mr-4 no-underline"
        ]
        [ text label ]


currentPage : Model -> Html Msg
currentPage model =
    let
        context =
            newContext model

        page =
            case model.page of
                Page_NotFound ->
                    NotFound.view

                Page_Account pageModel ->
                    Account.view context pageModel
                        |> map PageAccountMsg

                Page_Home pageModel ->
                    Home.view context pageModel
                        |> map PageHomeMsg

                Page_Invite pageModel ->
                    Invite.view context pageModel
                        |> map PageInviteMsg
    in
    section [ class "flex-auto" ]
        [ page ]


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
