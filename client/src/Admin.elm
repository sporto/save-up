module Admin exposing (main)

import Admin.AppLocation as AppLocation exposing (AppLocation)
import Admin.Navigation as Navigation
import Admin.Pages.Home as Home
import Admin.Pages.Invite as Invite
import Admin.Routes as Routes exposing (Route)
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Navigation exposing (Location)
import Shared.Context exposing (Context)
import Shared.Flags as Flags
import Shared.Sessions as Sessions


type alias Model =
    { flags : Flags.Flags
    , currentLocation : AppLocation
    , page : Page
    }


initialModel : Flags.Flags -> Location -> Model
initialModel flags location =
    { flags = flags
    , currentLocation = AppLocation.navigationLocationToAppLocation location
    , page = Page_Home
    }


init : Flags.Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    ( initialModel flags location
    , Cmd.none
    )
        |> initCurrentPage


type Msg
    = SignOut
    | NavigateTo Routes.Route
    | OnLocationChange Location
    | PageInviteMsg Invite.Msg


type Page
    = Page_Home
    | Page_Invite Invite.Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        context : Context
        context =
            { flags = model.flags
            }
    in
        case msg of
            SignOut ->
                ( model, Sessions.toJsSignOut () )

            NavigateTo route ->
                ( model, Navigation.setRoute route )

            OnLocationChange location ->
                let
                    _ =
                        Debug.log "location" location.pathname

                    newLocation =
                        AppLocation.navigationLocationToAppLocation location
                in
                    ( { model | currentLocation = newLocation }
                    , Cmd.none
                    )
                        |> initCurrentPage

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


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, cmds ) =
    let
        ( newPage, newCmd ) =
            case model.currentLocation.route of
                Routes.Route_Home ->
                    ( Page_Home, Cmd.none )

                Routes.Route_Invite ->
                    let
                        ( pageModel, pageCmd ) =
                            Invite.init
                    in
                        ( Page_Invite pageModel, Cmd.map PageInviteMsg pageCmd )

                Routes.Route_NotFound ->
                    ( Page_Home, Cmd.none )
    in
        ( { model | page = newPage }, Cmd.batch [ cmds, newCmd ] )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageSub =
            case model.page of
                Page_Home ->
                    Sub.none

                Page_Invite pageModel ->
                    Sub.map PageInviteMsg (Invite.subscriptions pageModel)
    in
        Sub.batch
            [ pageSub
            ]


view : Model -> Html Msg
view model =
    section []
        [ navigation model
        , currentPage model
        ]


navigation : Model -> Html Msg
navigation model =
    nav [ class "flex justify-between p-4 bg-black text-white" ]
        [ div []
            [ text "KIC" ]
        , div
            []
            [ navigationLink Routes.Route_Home "Home"
            , navigationLink Routes.Route_Invite "Invite"
            ]
        , div []
            [ text model.flags.token.name
            , a [ href "javascript://", class "text-white ml-3", onClick SignOut ] [ text "Log out" ]
            ]
        ]


navigationLink : Route -> String -> Html Msg
navigationLink route label =
    a
        [ href "javascript://"
        , onClick (NavigateTo route)
        , class "text-white mr-4"
        ]
        [ text label ]


currentPage : Model -> Html Msg
currentPage model =
    let
        page =
            case model.page of
                Page_Home ->
                    Home.view

                Page_Invite pageModel ->
                    Invite.view pageModel
                        |> map PageInviteMsg
    in
        section [ class "p-4" ]
            [ page
            , text (toString model.currentLocation.route)
            , text (toString model.page)
            ]


main : Program Flags.Flags Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
