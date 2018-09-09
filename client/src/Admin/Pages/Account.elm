module Admin.Pages.Account exposing (Model, Msg, init, subscriptions, update, view)

import Admin.Routes as Routes
import Html exposing (..)
import Html.Attributes exposing (class, href, src, style, type_)
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


view : Context -> Model -> Html Msg
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


currentPage : Context -> Model -> Html Msg
currentPage context model =
    case model.route of
        Routes.RouteAccount_Top ->
            div [ class molecules.page.container ]
                [ img [ src "https://via.placeholder.com/600x320" ] []
                ]

        Routes.RouteAccount_Deposit ->
            deposit
                context
                model

        Routes.RouteAccount_Withdraw ->
            div [ class molecules.page.container ]
                [ h1 [ class molecules.page.title ] [ text "Make a withdrawal" ]
                ]



--DEPOSIT


deposit : Context -> Model -> Html Msg
deposit context model =
    div [ class molecules.page.container, class "flex justify-center" ]
        [ div [ style "width" "24rem" ]
            [ h1 [ class molecules.page.title ] [ text "Make a deposit" ]
            , form [ class "mt-2" ]
                [ p [ class molecules.form.fieldset ]
                    [ label [ class molecules.form.label ] [ text "Amount" ]
                    , input [ class molecules.form.input, type_ "number" ] []
                    ]
                , p [ class molecules.form.actions ]
                    [ submitDeposit model
                    ]
                ]
            ]
        ]


submitDeposit : Model -> Html Msg
submitDeposit model =
    button [ class molecules.form.submit ]
        [ text "Deposit"
        ]


getData context =
    Cmd.none
