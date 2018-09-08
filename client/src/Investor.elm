module Investor exposing (main)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Investor.AppLocation as AppLocation exposing (AppLocation)
import Investor.Pages.Home as Home
import Investor.Routes as Routes exposing (Route)
import Shared.Context exposing (Context)
import Shared.Flags as Flags exposing (Flags)
import Shared.Pages.NotFound as NotFound
import Shared.Sessions as Sessions
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
    ( initialModel flags url key
    , Cmd.none
    )
        |> initCurrentPage


type Msg
    = SignOut
    | OnUrlChange Url
    | OnUrlRequest UrlRequest
    | PageHomeMsg Home.Msg


type Page
    = Page_Home Home.Model
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

        OnUrlRequest request ->
            ( model, Cmd.none )

        OnUrlChange url ->
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


newContext : Model -> Context
newContext model =
    { flags = model.flags
    }


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, cmds ) =
    let
        ( newPage, newCmd ) =
            case model.currentLocation.route of
                Routes.Route_Home ->
                    let
                        ( pageModel, cmd ) =
                            Home.init model.flags
                    in
                    ( Page_Home pageModel, Cmd.map PageHomeMsg cmd )

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

                Page_Home pageModel ->
                    Sub.map PageHomeMsg (Home.subscriptions pageModel)
    in
    Sub.batch
        [ pageSub
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "SaveUp"
    , body =
        [ navigation model
        , currentPage model
        ]
    }


navigation : Model -> Html Msg
navigation model =
    nav [ class "flex p-4 bg-blue text-white" ]
        [ Navigation.logo
        , div
            [ class "ml-8 flex-grow" ]
            []
        , div []
            [ Navigation.signOut SignOut
            ]
        ]


currentPage : Model -> Html Msg
currentPage model =
    let
        context =
            newContext model

        page =
            case model.page of
                Page_NotFound ->
                    NotFound.view

                Page_Home pageModel ->
                    Home.view context pageModel
                        |> map PageHomeMsg
    in
    section [ class "p-4" ]
        [ page
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
