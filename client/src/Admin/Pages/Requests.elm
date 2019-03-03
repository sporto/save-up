module Admin.Pages.Requests exposing (Model, Msg, init, subscriptions, update, view)

import Api.Enum.TransactionKind exposing (TransactionKind)
import Api.Enum.TransactionRequestState exposing (TransactionRequestState)
import Api.InputObject exposing (ResolveTransactionRequestInput)
import Api.Mutation
import Api.Object
import Api.Object.Account
import Api.Object.Admin
import Api.Object.ResolveTransactionRequestResponse
import Api.Object.TransactionRequest
import Api.Object.User
import Api.Query
import Browser.Navigation as Nav
import Dataset
import Dict exposing (Dict)
import Graphql.Field as Field
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.OptionalArgument as OptionalArgument
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, src, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Notifications
import Regex
import RemoteData
import Shared.Actions as Actions
import Shared.Css as Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl as GraphQl exposing (GraphData, GraphResponse, MutationError, mutationErrorSelection, sendMutation)
import Shared.Routes as Routes
import String.Verify
import Time exposing (Posix)
import UI.ChartV2 as Chart
import UI.ConfirmButton as ConfirmButton
import UI.Empty as Empty
import UI.Flash as Flash
import UI.Forms as Forms
import UI.Icons as Icons
import Verify exposing (Validator, validate, verify)


type Msg
    = OnData (GraphResponse Data)
    | Approve_Click Int
    | Approve_Commit Int
    | Reject_Click Int
    | Reject_Commit Int
    | AproveOrReject_Cancel
    | OnResolveResponse Int (GraphResponse ResolveTransactionRequestResponse)


type alias Model =
    { data : GraphData Data
    , confirmButton : Maybe RequestAction
    , responses : Dict Int (GraphData ResolveTransactionRequestResponse)
    }


newModel : Model
newModel =
    { data = RemoteData.NotAsked
    , confirmButton = Nothing
    , responses = Dict.empty
    }


type alias Data =
    { pendingRequests : List PendingRequest
    }


updateRequestInData : PendingRequest -> Data -> Data
updateRequestInData request data =
    { data
        | pendingRequests =
            Dataset.putOne
                { getId = .id }
                request
                data.pendingRequests
    }


type RequestAction
    = RequestAction_Approve Int
    | RequestAction_Reject Int


type alias PendingRequest =
    { id : Int
    , state : TransactionRequestState
    , amountInCents : Int
    , kind : TransactionKind
    , user : String
    }


type alias Returns =
    ( Model, Cmd Msg, Actions.Actions Msg )


init : Context -> Returns
init context =
    ( newModel, dataCmd context, Actions.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Context -> Msg -> Model -> Returns
update context msg model =
    case msg of
        OnData result ->
            case result of
                Err e ->
                    ( { model | data = RemoteData.Failure e }
                    , Cmd.none
                    , Actions.addErrorNotification
                        "Something went wrong"
                    )

                Ok data ->
                    ( { model | data = RemoteData.Success data }
                    , Cmd.none
                    , Actions.none
                    )

        Approve_Click id ->
            ( { model | confirmButton = Just (RequestAction_Approve id) }
            , Cmd.none
            , Actions.none
            )

        Approve_Commit id ->
            ( { model
                | responses = Dict.insert id RemoteData.Loading model.responses
              }
            , resoleMutationCmd context id Api.Enum.TransactionRequestState.Approved
            , Actions.none
            )

        Reject_Click id ->
            ( { model | confirmButton = Just (RequestAction_Reject id) }
            , Cmd.none
            , Actions.none
            )

        Reject_Commit id ->
            ( { model
                | responses = Dict.insert id RemoteData.Loading model.responses
              }
            , resoleMutationCmd context id Api.Enum.TransactionRequestState.Rejected
            , Actions.none
            )

        AproveOrReject_Cancel ->
            ( { model | confirmButton = Nothing }
            , Cmd.none
            , Actions.none
            )

        OnResolveResponse id result ->
            case result of
                Err e ->
                    ( { model
                        | responses =
                            Dict.insert
                                id
                                (RemoteData.Failure e)
                                model.responses
                      }
                    , Cmd.none
                    , Actions.addErrorNotification
                        "Something went wrong"
                    )

                Ok response ->
                    let
                        ( newData, action ) =
                            case response.transactionRequest of
                                Just transactionRequest ->
                                    ( RemoteData.map
                                        (updateRequestInData
                                            transactionRequest
                                        )
                                        model.data
                                    , Actions.addSuccessNotification
                                        "Saved"
                                    )

                                Nothing ->
                                    ( model.data, Actions.none )
                    in
                    ( { model
                        | data = newData
                        , responses =
                            Dict.insert
                                id
                                (RemoteData.Success response)
                                model.responses
                      }
                    , Cmd.none
                    , action
                    )


view : Context -> Model -> Html Msg
view context model =
    let
        inner =
            case model.data of
                RemoteData.NotAsked ->
                    Empty.loading

                RemoteData.Loading ->
                    Empty.loading

                RemoteData.Failure e ->
                    Empty.graphError e

                RemoteData.Success data ->
                    viewWithData context model data
    in
    section
        [ class molecules.page.container ]
        [ h1 [ class molecules.page.title, class "mb-4" ] [ text "Pending requests" ]
        , inner
        ]


viewWithData : Context -> Model -> Data -> Html Msg
viewWithData context model data =
    if List.isEmpty data.pendingRequests then
        Empty.noData "There are no pending requests"

    else
        div [] (List.map (requestView model) data.pendingRequests)


requestView : Model -> PendingRequest -> Html Msg
requestView model request =
    let
        id =
            request.id

        name =
            div [ class "text-2xl" ] [ text request.user ]

        amount =
            div []
                [ text "Balance: "
                , span [ class "text-3xl font-semibold" ] [ text formattedAmount ]
                , span [ class "ml-2" ] [ Icons.money ]
                ]

        formattedAmount =
            (request.amountInCents // 100)
                |> String.fromInt

        maybeActions =
            case Dict.get id model.responses of
                Just RemoteData.Loading ->
                    div [] [ Icons.spinner ]

                _ ->
                    actions

        actions =
            if request.state == Api.Enum.TransactionRequestState.Pending then
                div [ class "flex items-center" ]
                    [ btnApprove
                    , span [ class "ml-4" ] [ btnReject ]
                    ]

            else
                div []
                    [ text (Api.Enum.TransactionRequestState.toString request.state)
                    ]

        btnApprove =
            ConfirmButton.view
                "Approve"
                btnApproveArgs
                btnApproveState

        btnReject =
            ConfirmButton.view
                "Reject"
                btnRejectArgs
                btnRejectState

        btnApproveArgs =
            { click = Approve_Click id
            , commit = Approve_Commit id
            , cancel = AproveOrReject_Cancel
            }

        btnRejectArgs =
            { click = Reject_Click id
            , commit = Reject_Commit id
            , cancel = AproveOrReject_Cancel
            }

        btnApproveState =
            btnStateFor
                model
                (RequestAction_Approve id)

        btnRejectState =
            btnStateFor
                model
                (RequestAction_Reject id)

        left =
            div [ class "flex items-center" ]
                [ name
                , span [ class "ml-6" ] [ amount ]
                ]
    in
    div [ class "border p-4 rounded shadow-md mb-6 flex justify-between items-center" ]
        [ left, maybeActions ]


btnStateFor : Model -> RequestAction -> ConfirmButton.State
btnStateFor model action =
    case model.confirmButton of
        Nothing ->
            ConfirmButton.Initial

        Just selectedAction ->
            if selectedAction == action then
                ConfirmButton.Engaged

            else
                ConfirmButton.Initial



-- GraphQl


dataCmd : Context -> Cmd Msg
dataCmd context =
    GraphQl.sendQuery
        context
        "data-requests"
        dataQuery
        OnData


dataQuery : SelectionSet Data RootQuery
dataQuery =
    Api.Query.selection identity
        |> with (Api.Query.admin adminNode)


adminNode : SelectionSet Data Api.Object.Admin
adminNode =
    Api.Object.Admin.selection Data
        |> with (Api.Object.Admin.pendingRequests requestSelection)


requestSelection : SelectionSet PendingRequest Api.Object.TransactionRequest
requestSelection =
    Api.Object.TransactionRequest.selection PendingRequest
        |> with Api.Object.TransactionRequest.id
        |> with Api.Object.TransactionRequest.state
        |> with (Api.Object.TransactionRequest.amountInCents |> Field.map round)
        |> with Api.Object.TransactionRequest.kind
        |> with (Api.Object.TransactionRequest.account accountSelection)


accountSelection : SelectionSet String Api.Object.Account
accountSelection =
    Api.Object.Account.selection identity
        |> with (Api.Object.Account.user userSelection)


userSelection : SelectionSet String Api.Object.User
userSelection =
    Api.Object.User.selection identity
        |> with Api.Object.User.name



-- ResolveTransactionRequestResponse Mutation


type alias ResolveTransactionRequestResponse =
    { success : Bool
    , errors : List MutationError
    , transactionRequest : Maybe PendingRequest
    }


resoleMutationCmd : Context -> Int -> TransactionRequestState -> Cmd Msg
resoleMutationCmd context id outcome =
    sendMutation
        context
        "resolve-request"
        (resolveMutation id outcome)
        (OnResolveResponse id)


resolveMutation : Int -> TransactionRequestState -> SelectionSet ResolveTransactionRequestResponse RootMutation
resolveMutation id outcome =
    let
        input : ResolveTransactionRequestInput
        input =
            { transactionRequestId = id
            , outcome = outcome
            }
    in
    Api.Mutation.selection identity
        |> with
            (Api.Mutation.resolveTransactionRequest
                { input = input }
                resolveResponseSelection
            )


resolveResponseSelection : SelectionSet ResolveTransactionRequestResponse Api.Object.ResolveTransactionRequestResponse
resolveResponseSelection =
    Api.Object.ResolveTransactionRequestResponse.selection ResolveTransactionRequestResponse
        |> with Api.Object.ResolveTransactionRequestResponse.success
        |> with (Api.Object.ResolveTransactionRequestResponse.errors mutationErrorSelection)
        |> with (Api.Object.ResolveTransactionRequestResponse.transactionRequest requestSelection)
