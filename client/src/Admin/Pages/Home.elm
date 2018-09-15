module Admin.Pages.Home exposing (Model, Msg, init, subscriptions, update, view)

import Api.Object
import Api.Object.Account
import Api.Object.AdminViewer
import Api.Object.User
import Api.Query
import Graphql.Field as Field
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href)
import RemoteData
import Shared.Context exposing (Context)
import Shared.Css exposing (molecules)
import Shared.GraphQl as GraphQl exposing (GraphData, GraphResponse)
import Shared.Routes as Routes
import UI.Empty as Empty
import UI.Icons as Icons


type Msg
    = NoOp
    | OnData (GraphResponse Data)


type alias Model =
    { data : GraphData Data
    }


newModel =
    { data = RemoteData.NotAsked
    }


init : Context -> ( Model, Cmd Msg )
init context =
    ( newModel, getData context )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Context -> Msg -> Model -> ( Model, Cmd Msg )
update context msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        OnData result ->
            case result of
                Err e ->
                    ( { model
                        | data = RemoteData.Failure e
                      }
                    , Cmd.none
                    )

                Ok data ->
                    ( { model
                        | data = RemoteData.Success data
                      }
                    , Cmd.none
                    )


view : Context -> Model -> Html msg
view context model =
    section [ class molecules.page.container ]
        [ h1 [ class "mt-4" ] [ text "Welcome" ]
        , investors context model
        ]


investors : Context -> Model -> Html msg
investors context model =
    case model.data of
        RemoteData.NotAsked ->
            Empty.loading

        RemoteData.Loading ->
            Empty.loading

        RemoteData.Failure e ->
            Empty.graphError e

        RemoteData.Success data ->
            investorsData context data


investorsData : Context -> Data -> Html msg
investorsData context data =
    if List.isEmpty data.investors then
        p [ class "mt-4" ] [ text "You don't have any investors, please invite one by clicking the invite link above." ]

    else
        div [ class "mt-4" ]
            (List.map investorView data.investors)


investorView : Investor -> Html msg
investorView investor =
    div [ class "border p-4 rounded shadow-md" ]
        [ div [ class "text-xl" ] [ text investor.name ]
        , div [ class "mt-2" ] (List.map accountView investor.accounts)
        ]


accountView : Account -> Html msg
accountView account =
    let
        pathShow =
            Routes.pathFor <| Routes.routeForAdminAccountShow account.id

        pathDeposit =
            Routes.pathFor <| Routes.routeForAdminAccountDeposit account.id

        pathWithdraw =
            Routes.pathFor <| Routes.routeForAdminAccountWithdraw account.id

        balance =
            account.balanceInCents // 100
    in
    div [ class "flex items-center justify-between" ]
        [ div [] [ text "Balance: ", strong [ class "mr-1 text-3xl" ] [ text (String.fromInt balance) ], Icons.money ]
        , div []
            [ a
                [ href pathShow
                , class "mr-3"
                , class molecules.button.primary
                ]
                [ span [ class "mr-2" ] [ Icons.chart ], text "Show" ]
            , a
                [ href pathDeposit
                , class "mr-3"
                , class molecules.button.primary
                ]
                [ span [ class "mr-2" ] [ Icons.deposit ], text "Deposit" ]
            , a
                [ href pathWithdraw
                , class molecules.button.primary
                ]
                [ span [ class "mr-2" ] [ Icons.withdraw ], text "Withdraw" ]
            ]
        ]



-- DATA
-- We want balance
-- Investor name


type alias Data =
    { investors : List Investor
    }


type alias Investor =
    { accounts : List Account
    , name : String
    }


type alias Account =
    { id : Int
    , balanceInCents : Int
    , name : String
    }


getData : Context -> Cmd Msg
getData context =
    GraphQl.sendQuery
        context
        "data-home"
        dataQuery
        OnData


dataQuery : SelectionSet Data RootQuery
dataQuery =
    Api.Query.selection identity
        |> with (Api.Query.admin adminNode)


adminNode : SelectionSet Data Api.Object.AdminViewer
adminNode =
    Api.Object.AdminViewer.selection Data
        |> with (Api.Object.AdminViewer.investors investorNode)


investorNode : SelectionSet Investor Api.Object.User
investorNode =
    Api.Object.User.selection Investor
        |> with (Api.Object.User.accounts accountNode)
        |> with Api.Object.User.name


accountNode : SelectionSet Account Api.Object.Account
accountNode =
    Api.Object.Account.selection Account
        |> with Api.Object.Account.id
        |> with (Api.Object.Account.balanceInCents |> Field.map round)
        |> with Api.Object.Account.name
