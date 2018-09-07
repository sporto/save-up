module Public exposing (main)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Public.AppLocation as AppLocation exposing (AppLocation)
import Public.Pages.Invitation as Invitation
import Public.Pages.SignIn as SignIn
import Public.Pages.SignUp as SignUp
import Public.Routes as Routes exposing (Route)
import Shared.Context exposing (PublicContext)
import Shared.Flags as Flags exposing (PublicFlags)
import Shared.Sessions as Sessions
import Url exposing (Url)


type alias Model =
    { flags : PublicFlags
    , currentLocation : AppLocation
    , key : Nav.Key
    , page : Page
    }


initialModel : PublicFlags -> Url -> Nav.Key -> Model
initialModel flags url key =
    { flags = flags
    , currentLocation = AppLocation.fromUrl url
    , key = key
    , page = Page_Initial
    }


init : PublicFlags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( initialModel flags url key
    , Cmd.none
    )
        |> initCurrentPage


type Msg
    = OnUrlChange Url
    | OnUrlRequest UrlRequest
    | PageSignInMsg SignIn.Msg
    | PageSignUpMsg SignUp.Msg
    | PageInvitationMsg Invitation.Msg


type Page
    = Page_Initial
    | Page_SignIn SignIn.Model
    | Page_SignUp SignUp.Model
    | Page_Invitation Invitation.Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        context : PublicContext
        context =
            { flags = model.flags
            }
    in
    case msg of
        OnUrlChange url ->
            let
                newLocation =
                    AppLocation.fromUrl url
            in
            ( { model | currentLocation = newLocation }
            , Cmd.none
            )
                |> initCurrentPage

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

        PageSignInMsg sub ->
            case model.page of
                Page_SignIn pageModel ->
                    let
                        ( newPageModel, pageCmd ) =
                            SignIn.update
                                sub
                                pageModel
                    in
                    ( { model | page = Page_SignIn newPageModel }
                    , Cmd.map PageSignInMsg pageCmd
                    )

                _ ->
                    ( model, Cmd.none )

        PageSignUpMsg sub ->
            case model.page of
                Page_SignUp pageModel ->
                    let
                        ( newPageModel, pageCmd ) =
                            SignUp.update
                                sub
                                pageModel
                    in
                    ( { model | page = Page_SignUp newPageModel }
                    , Cmd.map PageSignUpMsg pageCmd
                    )

                _ ->
                    ( model, Cmd.none )

        PageInvitationMsg sub ->
            case model.page of
                Page_Invitation pageModel ->
                    let
                        ( newPageModel, pageCmd ) =
                            Invitation.update
                                sub
                                pageModel
                    in
                    ( { model | page = Page_Invitation newPageModel }
                    , Cmd.map PageInvitationMsg pageCmd
                    )

                _ ->
                    ( model, Cmd.none )


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, cmds ) =
    let
        ( newPage, newCmd ) =
            case model.currentLocation.route of
                Routes.Route_SignIn ->
                    let
                        ( pageModel, pageCmd ) =
                            SignIn.init model.flags
                    in
                    ( Page_SignIn pageModel, Cmd.map PageSignInMsg pageCmd )

                Routes.Route_SignUp ->
                    let
                        ( pageModel, pageCmd ) =
                            SignUp.init model.flags
                    in
                    ( Page_SignUp pageModel, Cmd.map PageSignUpMsg pageCmd )

                Routes.Route_Invitation token ->
                    let
                        ( pageModel, pageCmd ) =
                            Invitation.init model.flags token
                    in
                    ( Page_Invitation pageModel, Cmd.map PageInvitationMsg pageCmd )
    in
    ( { model | page = newPage }, Cmd.batch [ cmds, newCmd ] )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageSub =
            case model.page of
                Page_SignIn pageModel ->
                    Sub.map PageSignInMsg (SignIn.subscriptions pageModel)

                Page_SignUp pageModel ->
                    Sub.map PageSignUpMsg (SignUp.subscriptions pageModel)

                Page_Invitation pageModel ->
                    Sub.map PageInvitationMsg (Invitation.subscriptions pageModel)

                Page_Initial ->
                    Sub.none
    in
    Sub.batch
        [ pageSub
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "SaveUp"
    , body =
        [ currentPage model
        ]
    }


currentPage : Model -> Html Msg
currentPage model =
    let
        page =
            case model.page of
                Page_SignIn pageModel ->
                    SignIn.view pageModel
                        |> map PageSignInMsg

                Page_SignUp pageModel ->
                    SignUp.view pageModel
                        |> map PageSignUpMsg

                Page_Invitation pageModel ->
                    Invitation.view pageModel
                        |> map PageInvitationMsg

                Page_Initial ->
                    text ""
    in
    section [ class "p-4" ]
        [ page
        ]


main : Program PublicFlags Model Msg
main =
    Browser.application
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        , onUrlRequest = OnUrlRequest
        , onUrlChange = OnUrlChange
        }
