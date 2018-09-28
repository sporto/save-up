module Admin.Pages.Account exposing (Model, Msg, init, subscriptions, update, view)

import Api.Mutation
import Api.Object
import Api.Object.Account
import Api.Object.Admin
import Api.Object.DepositResponse
import Api.Object.Transaction
import Api.Query
import Graphql.Field as Field
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, src, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import RemoteData
import Shared.Actions as Actions exposing (Actions)
import Shared.Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl as GraphQl exposing (GraphData, GraphResponse, MutationError)
import Shared.Routes as Routes
import Time exposing (Posix)
import UI.Chart as Chart
import UI.Empty as Empty
import UI.Flash as Flash
import UI.Forms as Forms
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
    , yearlyInterest : Float
    }


type alias Transaction =
    { createdAt : Posix
    , balanceInCents : Int
    }


type alias DepositModel =
    { form : DepositForm
    , response : GraphData DepositResponse
    , validationErrors : Maybe ( ValidationError, List ValidationError )
    }


type alias ValidationError =
    ( Field, String )


type Field
    = Field_Amount


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
                        ( nextDepositModel, newCmd, newAction ) =
                            updateDeposit
                                context
                                model.accountID
                                subMsg
                                depositModel
                    in
                    ( { model | subPage = SubPage_Deposit nextDepositModel }
                    , Cmd.map Msg_Desposit newCmd
                    , Actions.map Msg_Desposit newAction
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


updateDeposit : Context -> ID -> DepositMsg -> DepositModel -> ( DepositModel, Cmd DepositMsg, Actions DepositMsg )
updateDeposit context accountID msg model =
    case msg of
        ChangeDepositAmount amount ->
            ( amount
                |> asAmountInDepositForm model.form
                |> asFormInDepositModel model
            , Cmd.none
            , Actions.none
            )

        OnDepositResponse result ->
            case result of
                Err e ->
                    ( { model | response = RemoteData.Failure e }
                    , Cmd.none
                    , Actions.addErrorNotification
                        "Something went wrong"
                    )

                Ok response ->
                    if response.success then
                        ( { model
                            | response = RemoteData.Success response
                            , form =
                                ""
                                    |> asAmountInDepositForm model.form
                          }
                        , Cmd.none
                        , Actions.addSuccessNotification
                            "Deposit sucessful"
                        )

                    else
                        ( { model | response = RemoteData.Success response }
                        , Cmd.none
                        , Actions.none
                        )

        SubmitDeposit ->
            case validateDeposit model.form of
                Ok form ->
                    ( { model
                        | response = RemoteData.Loading
                        , validationErrors = Nothing
                      }
                    , depositMutationCmd
                        context
                        accountID
                        (form.amount * 100)
                    , Actions.none
                    )

                Err errors ->
                    ( { model | validationErrors = Just errors }
                    , Cmd.none
                    , Actions.none
                    )


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

        balanceEl =
            div []
                [ text "Balance: "
                , span [ class "text-3xl font-semibold" ] [ text (String.fromInt balance) ]
                , span [ class "ml-2" ] [ Icons.money ]
                ]

        interestEl =
            div []
                [ span [ class "ml-8" ] [ text "Yearly interest" ]
                , span [ class "ml-2 text-2xl font-semibold" ] [ text (String.fromFloat account.yearlyInterest) ]
                , span [ class "ml-1 mr-2" ] [ text "%" ]
                , button [] [ Icons.edit ]
                ]
    in
    [ div [ class "flex items-center" ]
        [ balanceEl
        , interestEl
        ]
    , Chart.view account.transactions
    ]



-- Deposit Views


deposit : Context -> DepositModel -> Html DepositMsg
deposit context model =
    div [ class molecules.page.container, class "flex justify-center" ]
        [ div [ style "width" "24rem" ]
            [ Forms.form_ (formArgsDeposit model) ]
        ]


formArgsDeposit : DepositModel -> Forms.Args DepositResponse DepositMsg
formArgsDeposit model =
    { title = "Make a deposit"
    , intro = Nothing
    , submitContent = submitContentDeposit
    , fields = formFieldsDeposit model
    , onSubmit = SubmitDeposit
    , response = model.response
    }


submitContentDeposit =
    [ span [ class "mr-2" ] [ Icons.deposit ]
    , text "Deposit"
    ]


formFieldsDeposit : DepositModel -> List (Html DepositMsg)
formFieldsDeposit model =
    [ Forms.set
        Field_Amount
        "Amount"
        (input
            [ class molecules.form.input
            , onInput ChangeDepositAmount
            , type_ "number"
            , name "amount"
            , value model.form.amount
            ]
            []
        )
        model.validationErrors
    ]



-- Verify deposit


validateDeposit : Validator ValidationError DepositForm VerifiedDepositForm
validateDeposit =
    validate VerifiedDepositForm
        |> verify .amount (validateAmount ( Field_Amount, "Invalid amount" ))


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


adminNode : ID -> SelectionSet Account Api.Object.Admin
adminNode accountID =
    Api.Object.Admin.selection identity
        |> with (Api.Object.Admin.account { id = accountID } accountSelection)


accountSelection : SelectionSet Account Api.Object.Account
accountSelection =
    Api.Object.Account.selection Account
        |> with (Api.Object.Account.balanceInCents |> Field.map round)
        |> with (Api.Object.Account.transactions { since = 0 } transactionNode)
        |> with Api.Object.Account.yearlyInterest


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
