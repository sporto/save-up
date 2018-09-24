module Admin.Pages.Home exposing (Model, Msg, init, subscriptions, update, view)

import Api.Mutation
import Api.Object
import Api.Object.Account
import Api.Object.Admin
import Api.Object.ArchiveUserResponse
import Api.Object.User
import Api.Query
import Graphql.Field as Field
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Notifications
import RemoteData
import Shared.Actions as Actions
import Shared.Css as Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl as GraphQl exposing (GraphData, GraphResponse, MutationError)
import Shared.Routes as Routes
import UI.Empty as Empty
import UI.Icons as Icons


type Msg
    = NoOp
    | OnData (GraphResponse Data)
    | ArchiveInvestor Int
    | OnArchiveUserResponse Int (GraphResponse ArchiveUserResponse)


type alias ID =
    Int


type alias Model =
    { data : GraphData Data
    }


newModel =
    { data = RemoteData.NotAsked
    }


type alias Returns =
    ( Model, Cmd Msg, Actions.Actions Msg )


init : Context -> Returns
init context =
    ( newModel, getData context, Actions.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Context -> Msg -> Model -> Returns
update context msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none, Actions.none )

        ArchiveInvestor id ->
            ( model
            , archiveMutationCmd context id
            , Actions.none
            )

        OnArchiveUserResponse userID result ->
            case result of
                Err e ->
                    ( model
                    , Cmd.none
                    , Actions.addNotification failedArchiveNotification
                    )

                Ok response ->
                    if response.success then
                        let
                            nextModel =
                                { model | data = RemoteData.map updateData model.data }

                            updateData : Data -> Data
                            updateData data =
                                { data
                                    | investors = List.map setArchived data.investors
                                }

                            setArchived user =
                                if user.id == userID then
                                    { user | isArchived = True }

                                else
                                    user
                        in
                        ( nextModel
                        , Cmd.none
                        , Actions.addNotification successfulArchiveNotification
                        )

                    else
                        ( model, Cmd.none, Actions.addNotification failedArchiveNotification )

        OnData result ->
            case result of
                Err e ->
                    ( { model
                        | data = RemoteData.Failure e
                      }
                    , Cmd.none
                    , Actions.none
                    )

                Ok data ->
                    ( { model
                        | data = RemoteData.Success data
                      }
                    , Cmd.none
                    , Actions.none
                    )


successfulArchiveNotification =
    Notifications.newSuccess
        Css.notificationArgs
        "Investor archived"


failedArchiveNotification =
    Notifications.newError
        Css.notificationArgs
        "Failed archiving investor"


view : Context -> Model -> Html Msg
view context model =
    section [ class molecules.page.container ]
        [ h1 [ class molecules.page.title ] [ text "Welcome" ]
        , investors context model
        ]


investors : Context -> Model -> Html Msg
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


investorsData : Context -> Data -> Html Msg
investorsData context data =
    if List.isEmpty data.investors then
        p [ class "mt-4" ] [ text "You don't have any investors, please create one using the invite link above." ]

    else
        div [ class "mt-4" ]
            (List.map investorView data.investors)


investorView : Investor -> Html Msg
investorView investor =
    let
        btnArchive =
            if investor.isArchived then
                text ""

            else
                button [ onClick (ArchiveInvestor investor.id), class molecules.button.secondary, class "ml-3" ] [ text "Archive" ]
    in
    div [ class "border p-4 rounded shadow-md mb-6" ]
        [ div [ class "text-xl" ]
            [ text investor.name
            , btnArchive
            ]
        , div [ class "mt-5" ] (List.map accountView investor.accounts)
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
    { id : Int
    , accounts : List Account
    , name : String
    , isArchived : Bool
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


adminNode : SelectionSet Data Api.Object.Admin
adminNode =
    Api.Object.Admin.selection Data
        |> with (Api.Object.Admin.investors investorNode)


investorNode : SelectionSet Investor Api.Object.User
investorNode =
    Api.Object.User.selection Investor
        |> with Api.Object.User.id
        |> with (Api.Object.User.accounts accountNode)
        |> with Api.Object.User.name
        |> with Api.Object.User.isArchived


accountNode : SelectionSet Account Api.Object.Account
accountNode =
    Api.Object.Account.selection Account
        |> with Api.Object.Account.id
        |> with (Api.Object.Account.balanceInCents |> Field.map round)
        |> with Api.Object.Account.name



-- Archive mutation


type alias ArchiveUserResponse =
    { success : Bool
    , errors : List MutationError
    }


archiveMutationCmd : Context -> ID -> Cmd Msg
archiveMutationCmd context userID =
    GraphQl.sendMutation
        context
        "archive-user"
        (archiveMutation userID)
        (OnArchiveUserResponse userID)


archiveMutation : ID -> SelectionSet ArchiveUserResponse RootMutation
archiveMutation userID =
    Api.Mutation.selection identity
        |> with
            (Api.Mutation.archiveUser
                { userId = userID }
                archiveResponseSelection
            )


archiveResponseSelection : SelectionSet ArchiveUserResponse Api.Object.ArchiveUserResponse
archiveResponseSelection =
    Api.Object.ArchiveUserResponse.selection ArchiveUserResponse
        |> with Api.Object.ArchiveUserResponse.success
        |> with (Api.Object.ArchiveUserResponse.errors GraphQl.mutationErrorSelection)
