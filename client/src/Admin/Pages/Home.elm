module Admin.Pages.Home exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Api.Mutation
import Api.Object
import Api.Object.Account
import Api.Object.Admin
import Api.Object.ArchiveUserResponse
import Api.Object.UnarchiveUserResponse
import Api.Object.User
import Api.Query
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, hardcoded, with)
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
    | OnUnarchiveUserResponse Int (GraphResponse UnarchiveUserResponse)
    | UnarchiveInvestor Int


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
            ( setInvestorBusy id True model
            , archiveMutationCmd context id
            , Actions.none
            )

        OnArchiveUserResponse userID result ->
            case result of
                Err e ->
                    ( setInvestorBusy userID False model
                    , Cmd.none
                    , Actions.addNotification failedArchiveNotification
                    )

                Ok response ->
                    if response.success then
                        let
                            nextModel =
                                model
                                    |> setInvestorBusy userID False
                                    |> mapInvestorWithID userID (\inv -> { inv | isArchived = True })
                        in
                        ( nextModel
                        , Cmd.none
                        , Actions.addNotification successfulArchiveNotification
                        )

                    else
                        ( setInvestorBusy userID False model, Cmd.none, Actions.addNotification failedArchiveNotification )

        UnarchiveInvestor userID ->
            ( setInvestorBusy userID True model
            , unarchiveMutationCmd context userID
            , Actions.none
            )

        OnUnarchiveUserResponse userID result ->
            case result of
                Err e ->
                    ( setInvestorBusy userID False model
                    , Cmd.none
                    , Actions.addNotification failedUnarchiveNotification
                    )

                Ok response ->
                    if response.success then
                        let
                            nextModel =
                                model
                                    |> setInvestorBusy userID False
                                    |> mapInvestorWithID userID (\inv -> { inv | isArchived = False })
                        in
                        ( nextModel
                        , Cmd.none
                        , Actions.addNotification successfulUnarchiveNotification
                        )

                    else
                        ( setInvestorBusy userID False model, Cmd.none, Actions.addNotification failedUnarchiveNotification )

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


successfulUnarchiveNotification =
    Notifications.newSuccess
        Css.notificationArgs
        "Investor unarchived"


failedUnarchiveNotification =
    Notifications.newError
        Css.notificationArgs
        "Failed unarchiving investor"


setInvestorBusy : Int -> Bool -> Model -> Model
setInvestorBusy id value model =
    mapInvestorWithID id
        (\inv -> { inv | isBusy = value })
        model


mapInvestorWithID : Int -> (Investor -> Investor) -> Model -> Model
mapInvestorWithID id change model =
    mapInvestors
        (\inv ->
            if inv.id == id then
                change inv

            else
                inv
        )
        model


mapInvestors : (Investor -> Investor) -> Model -> Model
mapInvestors change model =
    let
        updateData : Data -> Data
        updateData data =
            { data
                | investors = List.map change data.investors
            }
    in
    { model | data = RemoteData.map updateData model.data }


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
        let
            ( archived, unarchived ) =
                List.partition (\inv -> inv.isArchived) data.investors

            archivedTitle =
                if List.isEmpty archived then
                    text ""

                else
                    h3 [ class "mt-8 mb-3 text-grey-dark" ] [ text "Archived" ]
        in
        div [ class "mt-4" ]
            [ div [] (List.map investorView unarchived)
            , archivedTitle
            , div [] (List.map investorView archived)
            ]


investorView : Investor -> Html Msg
investorView investor =
    let
        accounts =
            if investor.isArchived then
                text ""

            else
                div [ class "mt-5" ] (List.map accountView investor.accounts)
    in
    div [ class "border p-4 rounded shadow-md mb-6" ]
        [ div [ class "text-xl flex items-center" ]
            [ text investor.name
            , investorActions investor
            ]
        , accounts
        ]


investorActions : Investor -> Html Msg
investorActions investor =
    let
        actions =
            if investor.isBusy then
                [ Icons.spinner ]

            else
                [ btnArchive investor
                , btnUnarchive investor
                ]
    in
    div [ class "ml-2" ] actions


btnArchive investor =
    if investor.isArchived then
        text ""

    else
        button [ onClick (ArchiveInvestor investor.id), class molecules.button.secondary, class "ml-3" ] [ text "Archive" ]


btnUnarchive investor =
    if investor.isArchived then
        button [ onClick (UnarchiveInvestor investor.id), class molecules.button.secondary, class "ml-3" ] [ text "Unarchive" ]

    else
        text ""


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
    , isBusy : Bool
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
    SelectionSet.succeed identity
        |> with (Api.Query.admin adminNode)


adminNode : SelectionSet Data Api.Object.Admin
adminNode =
    SelectionSet.succeed Data
        |> with (Api.Object.Admin.investors investorNode)


investorNode : SelectionSet Investor Api.Object.User
investorNode =
    SelectionSet.succeed Investor
        |> with Api.Object.User.id
        |> with (Api.Object.User.accounts accountNode)
        |> with Api.Object.User.name
        |> with Api.Object.User.isArchived
        |> hardcoded False


accountNode : SelectionSet Account Api.Object.Account
accountNode =
    SelectionSet.succeed Account
        |> with Api.Object.Account.id
        |> with (Api.Object.Account.balanceInCents |> SelectionSet.map round)
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
    SelectionSet.succeed identity
        |> with
            (Api.Mutation.archiveUser
                { userId = userID }
                archiveResponseSelection
            )


archiveResponseSelection : SelectionSet ArchiveUserResponse Api.Object.ArchiveUserResponse
archiveResponseSelection =
    SelectionSet.succeed ArchiveUserResponse
        |> with Api.Object.ArchiveUserResponse.success
        |> with (Api.Object.ArchiveUserResponse.errors GraphQl.mutationErrorSelection)



-- Unarchive mutation


type alias UnarchiveUserResponse =
    { success : Bool
    , errors : List MutationError
    }


unarchiveMutationCmd : Context -> ID -> Cmd Msg
unarchiveMutationCmd context userID =
    GraphQl.sendMutation
        context
        "unarchive-user"
        (unarchiveMutation userID)
        (OnUnarchiveUserResponse userID)


unarchiveMutation : ID -> SelectionSet UnarchiveUserResponse RootMutation
unarchiveMutation userID =
    SelectionSet.succeed identity
        |> with
            (Api.Mutation.unarchiveUser
                { userId = userID }
                unarchiveResponseSelection
            )


unarchiveResponseSelection : SelectionSet UnarchiveUserResponse Api.Object.UnarchiveUserResponse
unarchiveResponseSelection =
    SelectionSet.succeed UnarchiveUserResponse
        |> with Api.Object.UnarchiveUserResponse.success
        |> with (Api.Object.UnarchiveUserResponse.errors GraphQl.mutationErrorSelection)
