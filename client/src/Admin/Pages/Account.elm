module Admin.Pages.Account exposing (Model, Msg, init, subscriptions, update, view)

import Admin.Routes as Routes
import Html exposing (..)
import Html.Attributes exposing (class, href, src)
import Shared.Context exposing (Context)
import Shared.Css exposing (molecules)


type alias ID =
    Int


type alias Model =
    { accountID : Int
    , route : Routes.RouteAccount
    }


newModel : ID -> Routes.RouteAccount -> Model
newModel accountID route =
    { accountID = accountID
    , route = route
    }


type Msg
    = NoOp


init : Context -> ID -> Routes.RouteAccount -> ( Model, Cmd Msg )
init context accountID route =
    ( newModel accountID route, getData context )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Context -> Msg -> Model -> ( Model, Cmd Msg )
update context msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : Context -> Model -> Html msg
view context model =
    section []
        [ navigation context model
        , currentPage context model
        ]


navigation : Context -> Model -> Html msg
navigation context model =
    let
        routeShow =
            Routes.routeForAccountShow model.accountID

        routeDeposit =
            Routes.routeForAccountDeposit model.accountID

        routeWithdraw =
            Routes.routeForAccountWithdraw model.accountID
    in
    nav [ class "p-4 bg-teal" ]
        [ navigationLink routeShow "Account"
        , navigationLink routeDeposit "Deposit"
        , navigationLink routeWithdraw "Withdraw"
        ]


navigationLink : Routes.Route -> String -> Html msg
navigationLink route label =
    a
        [ href (Routes.pathFor route)
        , class "text-white mr-4 no-underline"
        ]
        [ text label ]


currentPage context model =
    case model.route of
        Routes.RouteAccount_Top ->
            div [ class molecules.page.container ]
                [ img [ src "https://via.placeholder.com/600x320" ] []
                ]

        Routes.RouteAccount_Deposit ->
            div [ class molecules.page.container ]
                [ h1 [] [ text "Make a deposit" ]
                ]

        Routes.RouteAccount_Withdraw ->
            div [ class molecules.page.container ]
                [ h1 [] [ text "Make a withdrawal" ]
                ]


getData context =
    Cmd.none
