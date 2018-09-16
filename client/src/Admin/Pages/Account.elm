module Admin.Pages.Account exposing (Model, Msg, init, subscriptions, update, view)

import Api.Mutation
import Api.Object
import Api.Object.Account
import Api.Object.AdminViewer
import Api.Object.DepositResponse
import Api.Object.Transaction
import Api.Query
import Graphql.Field as Field
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, src, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import RemoteData
import Shared.Actions as Actions
import Shared.Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl as GraphQl exposing (GraphData, GraphResponse, MutationError)
import Shared.Routes as Routes
import Time exposing (Posix)
import UI.Empty as Empty
import UI.Flash as Flash
import UI.Icons as Icons
import Verify exposing (Validator, validate, verify)


type alias ID =
    Int


type alias Model =
    { accountID : Int
    , subPage : SubPage
    }


newModel : ID -> SubPage -> Model
newModel accountID subPage =
    { accountID = accountID
    , subPage = subPage
    }


type SubPage
    = SubPage_Top TopModel
    | SubPage_Deposit DepositModel
    | SubPage_Withdraw


type alias TopModel =
    { data : GraphData Account
    }


newTopModel : TopModel
newTopModel =
    { data = RemoteData.NotAsked
    }


type alias Account =
    { balanceInCents : Int
    , transactions : List Transaction
    }


type alias Transaction =
    { createdAt : Posix
    , balanceInCents : Int
    }


type alias DepositModel =
    { form : DepositForm
    , response : GraphData DepositResponse
    , validationErrors : Maybe ValidationErrors
    }


type alias ValidationErrors =
    ( String, List String )


newDepositModel : DepositModel
newDepositModel =
    { form =
        { amount = ""
        }
    , response = RemoteData.NotAsked
    , validationErrors = Nothing
    }


asFormInDepositModel model form =
    { model | form = form }


type alias DepositForm =
    { amount : String }


type alias VerifiedDepositForm =
    { amount : Int
    }


asAmountInDepositForm form amount =
    { form | amount = amount }


type Msg
    = NoOp
    | Msg_Desposit DepositMsg
    | OnAccountData (GraphResponse Account)


type DepositMsg
    = OnDepositResponse (GraphResponse DepositResponse)
    | ChangeDepositAmount String
    | SubmitDeposit


type alias Returns =
    ( Model, Cmd Msg, Actions.Actions Msg )


init : Context -> ID -> Routes.RouteInAdminInAccount -> Returns
init context accountID route =
    let
        ( subPage, cmd ) =
            case route of
                Routes.RouteInAdminInAccount_Top ->
                    ( SubPage_Top newTopModel, accountQueryCmd context accountID )

                Routes.RouteInAdminInAccount_Deposit ->
                    ( SubPage_Deposit newDepositModel, Cmd.none )

                Routes.RouteInAdminInAccount_Withdraw ->
                    ( SubPage_Withdraw, Cmd.none )
    in
    ( newModel accountID subPage
    , cmd
    , Actions.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Context -> Msg -> Model -> Returns
update context msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none, Actions.none )

        Msg_Desposit subMsg ->
            case model.subPage of
                SubPage_Deposit depositModel ->
                    let
                        ( nextDepositModel, newCmd ) =
                            updateDeposit
                                context
                                model.accountID
                                subMsg
                                depositModel
                    in
                    ( { model | subPage = SubPage_Deposit nextDepositModel }
                    , Cmd.map Msg_Desposit newCmd
                    , Actions.none
                    )

                _ ->
                    ( model, Cmd.none, Actions.none )

        OnAccountData result ->
            case result of
                Err e ->
                    ( { model
                        | subPage = SubPage_Top { data = RemoteData.Failure e }
                      }
                    , Cmd.none
                    , Actions.none
                    )

                Ok data ->
                    ( { model
                        | subPage = SubPage_Top { data = RemoteData.Success data }
                      }
                    , Cmd.none
                    , Actions.none
                    )


updateDeposit : Context -> ID -> DepositMsg -> DepositModel -> ( DepositModel, Cmd DepositMsg )
updateDeposit context accountID msg model =
    case msg of
        ChangeDepositAmount amount ->
            ( amount
                |> asAmountInDepositForm model.form
                |> asFormInDepositModel model
            , Cmd.none
            )

        OnDepositResponse result ->
            case result of
                Err e ->
                    ( { model | response = RemoteData.Failure e }, Cmd.none )

                Ok response ->
                    if response.success then
                        ( { model
                            | response = RemoteData.Success response
                            , form =
                                ""
                                    |> asAmountInDepositForm model.form
                          }
                        , Cmd.none
                        )

                    else
                        ( { model | response = RemoteData.Success response }
                        , Cmd.none
                        )

        SubmitDeposit ->
            case depositValidator model.form of
                Ok form ->
                    ( { model
                        | response = RemoteData.Loading
                        , validationErrors = Nothing
                      }
                    , depositMutationCmd
                        context
                        accountID
                        (form.amount * 100)
                    )

                Err errors ->
                    ( { model | validationErrors = Just errors }, Cmd.none )


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
            Routes.routeForAdminAccountShow model.accountID

        routeDeposit =
            Routes.routeForAdminAccountDeposit model.accountID

        routeWithdraw =
            Routes.routeForAdminAccountWithdraw model.accountID
    in
    nav [ class "p-4 bg-indigo-light" ]
        [ navigationLink routeShow "Account"
        , navigationLink routeDeposit "Deposit"
        , navigationLink routeWithdraw "Withdraw"
        ]


navigationLink : Routes.Route -> String -> Html msg
navigationLink route label =
    a
        [ href (Routes.pathFor route)
        , class "text-white mr-6 no-underline"
        ]
        [ text label ]


currentPage : Context -> Model -> Html Msg
currentPage context model =
    case model.subPage of
        SubPage_Top topModel ->
            accountView
                context
                topModel

        SubPage_Deposit depositModel ->
            deposit
                context
                depositModel
                |> map Msg_Desposit

        SubPage_Withdraw ->
            div [ class molecules.page.container ]
                [ h1 [ class molecules.page.title ] [ text "Make a withdrawal" ]
                ]



-- Account view


accountView : Context -> TopModel -> Html msg
accountView context model =
    let
        inner =
            case model.data of
                RemoteData.NotAsked ->
                    [ Empty.loading ]

                RemoteData.Loading ->
                    [ Empty.loading ]

                RemoteData.Failure e ->
                    [ Empty.graphError e ]

                RemoteData.Success data ->
                    accountWithData context data
    in
    div [ class molecules.page.container ] inner


accountWithData : Context -> Account -> List (Html msg)
accountWithData context account =
    let
        balance =
            account.balanceInCents // 100
    in
    [ div []
        [ text "Balance: "
        , span [ class "text-3xl font-semibold" ] [ text (String.fromInt balance) ]
        , span [ class "ml-2" ] [ Icons.money ]
        ]
    , img [ src "https://via.placeholder.com/600x320" ] []
    ]



-- Deposit Views


deposit : Context -> DepositModel -> Html DepositMsg
deposit context model =
    div [ class molecules.page.container, class "flex justify-center" ]
        [ div [ style "width" "24rem" ]
            [ h1 [ class molecules.page.title ] [ text "Make a deposit" ]
            , form [ class "mt-2", onSubmit SubmitDeposit ]
                [ flashDeposit model
                , validationErrorsView model.validationErrors
                , p [ class molecules.form.fieldset ]
                    [ label [ class molecules.form.label ] [ text "Amount" ]
                    , input
                        [ class molecules.form.input
                        , type_ "number"
                        , onInput ChangeDepositAmount
                        , value model.form.amount
                        ]
                        []
                    ]
                , p [ class molecules.form.actions ]
                    [ submitDeposit model
                    ]
                ]
            ]
        ]


submitDeposit : DepositModel -> Html msg
submitDeposit model =
    case model.response of
        RemoteData.Loading ->
            Icons.spinner

        _ ->
            button [ class molecules.button.primary ]
                [ span [ class "mr-2" ] [ Icons.deposit ]
                , text "Deposit"
                ]


flashDeposit : DepositModel -> Html msg
flashDeposit model =
    case model.response of
        RemoteData.Success response ->
            if response.success then
                Flash.success
                    "Deposit saved"

            else
                text ""

        RemoteData.Failure e ->
            Flash.error
                "Something went wrong"

        _ ->
            text ""



-- Verify deposit


depositValidator : Validator String DepositForm VerifiedDepositForm
depositValidator =
    validate VerifiedDepositForm
        |> verify .amount (validateAmount "Invalid amount")


validateAmount : error -> Validator error String Int
validateAmount error input =
    case String.toInt input of
        Just int ->
            if int > 0 then
                Ok int

            else
                Err ( error, [] )

        Nothing ->
            Err ( error, [] )



-- Common views


validationErrorsView : Maybe ValidationErrors -> Html msg
validationErrorsView maybeValidationErrorsView =
    case maybeValidationErrorsView of
        Nothing ->
            text ""

        Just ( firstError, other ) ->
            Flash.error firstError



-- GraphQl


accountQueryCmd : Context -> ID -> Cmd Msg
accountQueryCmd context accountID =
    GraphQl.sendQuery
        context
        "account"
        (accountQuery accountID)
        OnAccountData


accountQuery : ID -> SelectionSet Account RootQuery
accountQuery accountID =
    Api.Query.selection identity
        |> with (Api.Query.admin <| adminNode accountID)


adminNode : ID -> SelectionSet Account Api.Object.AdminViewer
adminNode accountID =
    Api.Object.AdminViewer.selection identity
        |> with (Api.Object.AdminViewer.account { id = accountID } accountNode)


accountNode : SelectionSet Account Api.Object.Account
accountNode =
    Api.Object.Account.selection Account
        |> with (Api.Object.Account.balanceInCents |> Field.map round)
        |> with (Api.Object.Account.transactions { since = 0 } transactionNode)


transactionNode : SelectionSet Transaction Api.Object.Transaction
transactionNode =
    Api.Object.Transaction.selection Transaction
        |> with (Api.Object.Transaction.createdAt |> Field.mapOrFail GraphQl.unwrapNaiveDateTime)
        |> with (Api.Object.Transaction.balanceInCents |> Field.map round)


type alias DepositResponse =
    { success : Bool
    , errors : List MutationError
    }


depositMutationCmd : Context -> ID -> Int -> Cmd DepositMsg
depositMutationCmd context accountID cents =
    GraphQl.sendMutation
        context
        "create-deposit"
        (depositMutation accountID cents)
        OnDepositResponse


depositMutation : ID -> Int -> SelectionSet DepositResponse RootMutation
depositMutation accountID cents =
    Api.Mutation.selection identity
        |> with
            (Api.Mutation.deposit
                { input = { accountId = accountID, cents = cents } }
                depositResponseSelection
            )


depositResponseSelection : SelectionSet DepositResponse Api.Object.DepositResponse
depositResponseSelection =
    Api.Object.DepositResponse.selection DepositResponse
        |> with Api.Object.DepositResponse.success
        |> with (Api.Object.DepositResponse.errors GraphQl.mutationErrorSelection)
