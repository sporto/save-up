module Admin.Pages.Account exposing (Model, Msg, init, subscriptions, update, view)

import Api.InputObject
import Api.Mutation
import Api.Object
import Api.Object.Account
import Api.Object.Admin
import Api.Object.ChangeAccountInterestResponse
import Api.Object.DepositResponse
import Api.Object.Transaction
import Api.Object.WithdrawalResponse
import Api.Query
import Browser.Navigation as Nav
import Graphql.Field as Field
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, src, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import RemoteData
import Shared.Actions as Actions exposing (Actions)
import Shared.Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl as GraphQl exposing (GraphData, GraphResponse, MutationError)
import Shared.Return3 as Return3
import Shared.Routes as Routes
import Time exposing (Posix)
import UI.AccountInfo as AccountInfo
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
    | SubPage_Withdraw WithdrawModel


type alias TopModel =
    { data : GraphData Account
    , yearlyInterestInput : Maybe String
    , yearlyInterestResponse : GraphData ChangeAccountInterestResponse
    }


newTopModel : TopModel
newTopModel =
    { data = RemoteData.NotAsked
    , yearlyInterestInput = Nothing
    , yearlyInterestResponse = RemoteData.NotAsked
    }


type alias ChangeAccountInterestResponse =
    { success : Bool
    , errors : List MutationError
    , account : Maybe Account
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


type alias WithdrawModel =
    { form : WithdrawForm
    , response : GraphData WithdrawalResponse
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


newWithdrawModel : WithdrawModel
newWithdrawModel =
    { form =
        { amount = ""
        }
    , response = RemoteData.NotAsked
    , validationErrors = Nothing
    }


asFormInWithdrawModel model form =
    { model | form = form }


type alias WithdrawForm =
    { amount : String }


type alias VerifiedWithdrawForm =
    { amount : Int
    }


asAmountInWithdrawForm form amount =
    { form | amount = amount }


type Msg
    = NoOp
    | Msg_Top TopMsg
    | Msg_Desposit DepositMsg
    | Msg_Withdraw WithdrawMsg
    | OnAccountData (GraphResponse Account)


type TopMsg
    = EditInterestRate
    | CancelInterestRate
    | ChangeInterestRate String
    | SaveInterestRate String
    | OnSaveInterestRateResponse (GraphResponse ChangeAccountInterestResponse)


type DepositMsg
    = OnDepositResponse (GraphResponse DepositResponse)
    | ChangeDepositAmount String
    | SubmitDeposit


type WithdrawMsg
    = OnWithdrawalResponse (GraphResponse WithdrawalResponse)
    | ChangeWithdrawAmount String
    | SubmitWithdraw


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
                    ( SubPage_Withdraw newWithdrawModel, Cmd.none )
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

        Msg_Top subMsg ->
            case model.subPage of
                SubPage_Top subModel ->
                    updateTop
                        context
                        model.accountID
                        subMsg
                        subModel
                        |> Return3.mapAll
                            (\p -> { model | subPage = SubPage_Top p })
                            Msg_Top

                _ ->
                    ( model, Cmd.none, Actions.none )

        Msg_Desposit subMsg ->
            case model.subPage of
                SubPage_Deposit depositModel ->
                    updateDeposit
                        context
                        model.accountID
                        subMsg
                        depositModel
                        |> Return3.mapAll
                            (\p -> { model | subPage = SubPage_Deposit p })
                            Msg_Desposit

                _ ->
                    ( model, Cmd.none, Actions.none )

        Msg_Withdraw subMsg ->
            case model.subPage of
                SubPage_Withdraw subModel ->
                    updateWithdraw
                        context
                        model.accountID
                        subMsg
                        subModel
                        |> Return3.mapAll
                            (\p -> { model | subPage = SubPage_Withdraw p })
                            Msg_Withdraw

                _ ->
                    ( model, Cmd.none, Actions.none )

        OnAccountData result ->
            case result of
                Err e ->
                    ( { model
                        | subPage =
                            SubPage_Top
                                { newTopModel
                                    | data = RemoteData.Failure e
                                }
                      }
                    , Cmd.none
                    , Actions.none
                    )

                Ok data ->
                    ( { model
                        | subPage =
                            SubPage_Top
                                { newTopModel
                                    | data = RemoteData.Success data
                                }
                      }
                    , Cmd.none
                    , Actions.none
                    )


updateTop : Context -> ID -> TopMsg -> TopModel -> ( TopModel, Cmd TopMsg, Actions TopMsg )
updateTop context accountID msg model =
    case msg of
        EditInterestRate ->
            case model.data of
                RemoteData.Success account ->
                    ( { model
                        | yearlyInterestInput = Just (String.fromFloat account.yearlyInterest)
                      }
                    , Cmd.none
                    , Actions.none
                    )

                _ ->
                    Return3.noOp model

        CancelInterestRate ->
            ( { model
                | yearlyInterestInput = Nothing
                , yearlyInterestResponse = RemoteData.NotAsked
              }
            , Cmd.none
            , Actions.none
            )

        ChangeInterestRate rate ->
            ( { model | yearlyInterestInput = Just rate }
            , Cmd.none
            , Actions.none
            )

        SaveInterestRate rate ->
            case validateInterestRate rate of
                Ok float ->
                    ( { model
                        | yearlyInterestResponse = RemoteData.Loading
                      }
                    , changeInterestMutationCmd
                        context
                        accountID
                        float
                    , Actions.none
                    )

                Err ( e, _ ) ->
                    ( model
                    , Cmd.none
                    , Actions.addErrorNotification e
                    )

        OnSaveInterestRateResponse result ->
            case result of
                Err e ->
                    ( { model | yearlyInterestResponse = RemoteData.Failure e }
                    , Cmd.none
                    , Actions.addErrorNotification
                        "Something went wrong"
                    )

                Ok response ->
                    case response.account of
                        Just account ->
                            ( { model
                                | yearlyInterestResponse = RemoteData.Success response
                                , yearlyInterestInput = Nothing
                                , data = RemoteData.Success account
                              }
                            , Cmd.none
                            , Actions.addSuccessNotification
                                "Interest rate updated"
                            )

                        Nothing ->
                            ( { model
                                | yearlyInterestResponse = RemoteData.Success response
                              }
                            , Cmd.none
                            , Actions.none
                            )


validateInterestRate : Validator String String Float
validateInterestRate input =
    if String.isEmpty input then
        Err ( "Enter a yearly rate", [] )

    else
        case String.toFloat input of
            Nothing ->
                Err ( "Not a valid number", [] )

            Just n ->
                if n < 0 then
                    Err ( "Cannot be less than zero", [] )

                else if n > 1000 then
                    Err ( "Cannot be more than 1,000%", [] )

                else
                    Ok n


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
                        , Nav.pushUrl context.navKey (Routes.pathFor <| Routes.routeForAdminAccountShow accountID)
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


updateWithdraw : Context -> ID -> WithdrawMsg -> WithdrawModel -> ( WithdrawModel, Cmd WithdrawMsg, Actions WithdrawMsg )
updateWithdraw context accountID msg model =
    case msg of
        ChangeWithdrawAmount amount ->
            ( amount
                |> asAmountInWithdrawForm model.form
                |> asFormInWithdrawModel model
            , Cmd.none
            , Actions.none
            )

        OnWithdrawalResponse result ->
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
                                    |> asAmountInWithdrawForm model.form
                          }
                        , Nav.pushUrl context.navKey (Routes.pathFor <| Routes.routeForAdminAccountShow accountID)
                        , Actions.addSuccessNotification
                            "Withdrawal sucessful"
                        )

                    else
                        ( { model | response = RemoteData.Success response }
                        , Cmd.none
                        , Actions.none
                        )

        SubmitWithdraw ->
            case validateWithdraw model.form of
                Ok form ->
                    ( { model
                        | response = RemoteData.Loading
                        , validationErrors = Nothing
                      }
                    , withdrawMutationCmd
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
                |> map Msg_Top

        SubPage_Deposit depositModel ->
            deposit
                context
                depositModel
                |> map Msg_Desposit

        SubPage_Withdraw subModel ->
            withdraw
                context
                subModel
                |> map Msg_Withdraw



-- Account view


accountView : Context -> TopModel -> Html TopMsg
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
                    accountWithData context model data
    in
    div [ class molecules.page.container ] inner


accountWithData : Context -> TopModel -> Account -> List (Html TopMsg)
accountWithData context model account =
    let
        maybeInputField =
            case model.yearlyInterestInput of
                Nothing ->
                    Nothing

                Just rate ->
                    let
                        inputOrSpinner : List (Html TopMsg)
                        inputOrSpinner =
                            case model.yearlyInterestResponse of
                                RemoteData.Loading ->
                                    [ Icons.spinner ]

                                _ ->
                                    [ span [ style "width" "5rem" ]
                                        [ inputField
                                        ]
                                    , span [ class "ml-2" ] [ btnSave ]
                                    , span [ class "ml-2" ] [ btnCancel ]
                                    ]

                        inputField =
                            input
                                [ type_ "number"
                                , onInput ChangeInterestRate
                                , value rate
                                , class molecules.form.input
                                ]
                                []

                        btnSave =
                            button
                                [ onClick (SaveInterestRate rate)
                                , class molecules.button.primary
                                ]
                                [ text "Save" ]

                        btnCancel =
                            button
                                [ onClick CancelInterestRate
                                , class molecules.button.secondary
                                ]
                                [ text "Cancel" ]
                    in
                    Just
                        (div [ class "ml-2 flex items-center" ]
                            inputOrSpinner
                        )
    in
    [ AccountInfo.view
        { canAdmin = True, onEdit = EditInterestRate }
        account
        maybeInputField
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



-- Withdraw Views


withdraw : Context -> WithdrawModel -> Html WithdrawMsg
withdraw context model =
    div [ class molecules.page.container, class "flex justify-center" ]
        [ div [ style "width" "24rem" ]
            [ Forms.form_ (formArgsWithdraw model) ]
        ]


formArgsWithdraw : WithdrawModel -> Forms.Args WithdrawalResponse WithdrawMsg
formArgsWithdraw model =
    { title = "Make a withdrawal"
    , intro = Nothing
    , submitContent = submitContentWithdraw
    , fields = formFieldsWithdraw model
    , onSubmit = SubmitWithdraw
    , response = model.response
    }


submitContentWithdraw =
    [ span [ class "mr-2" ] [ Icons.withdraw ]
    , text "Withdraw"
    ]


formFieldsWithdraw : WithdrawModel -> List (Html WithdrawMsg)
formFieldsWithdraw model =
    [ Forms.set
        Field_Amount
        "Amount"
        (input
            [ class molecules.form.input
            , onInput ChangeWithdrawAmount
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


validateWithdraw : Validator ValidationError WithdrawForm VerifiedWithdrawForm
validateWithdraw =
    validate VerifiedWithdrawForm
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



-- Deposit


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



-- Withdrawal


type alias WithdrawalResponse =
    { success : Bool
    , errors : List MutationError
    }


withdrawMutationCmd : Context -> ID -> Int -> Cmd WithdrawMsg
withdrawMutationCmd context accountID cents =
    GraphQl.sendMutation
        context
        "create-withdrawal"
        (withdrawMutation accountID cents)
        OnWithdrawalResponse


withdrawMutation : ID -> Int -> SelectionSet WithdrawalResponse RootMutation
withdrawMutation accountID cents =
    Api.Mutation.selection identity
        |> with
            (Api.Mutation.withdraw
                { input = { accountId = accountID, cents = cents } }
                withdrawResponseSelection
            )


withdrawResponseSelection : SelectionSet WithdrawalResponse Api.Object.WithdrawalResponse
withdrawResponseSelection =
    Api.Object.WithdrawalResponse.selection WithdrawalResponse
        |> with Api.Object.WithdrawalResponse.success
        |> with (Api.Object.WithdrawalResponse.errors GraphQl.mutationErrorSelection)



-- Change interest mutation


changeInterestMutationCmd : Context -> ID -> Float -> Cmd TopMsg
changeInterestMutationCmd context accountID rate =
    GraphQl.sendMutation
        context
        "change-interest-rate"
        (changeInterestMutation accountID rate)
        OnSaveInterestRateResponse


changeInterestMutation : ID -> Float -> SelectionSet ChangeAccountInterestResponse RootMutation
changeInterestMutation accountID rate =
    let
        input : Api.InputObject.ChangeAccountInterestInput
        input =
            { accountId = accountID, yearlyInterest = rate }
    in
    Api.Mutation.selection identity
        |> with
            (Api.Mutation.changeAccountInterest
                { input = input }
                interestResponseSelection
            )


interestResponseSelection : SelectionSet ChangeAccountInterestResponse Api.Object.ChangeAccountInterestResponse
interestResponseSelection =
    Api.Object.ChangeAccountInterestResponse.selection ChangeAccountInterestResponse
        |> with Api.Object.ChangeAccountInterestResponse.success
        |> with (Api.Object.ChangeAccountInterestResponse.errors GraphQl.mutationErrorSelection)
        |> with (Api.Object.ChangeAccountInterestResponse.account accountSelection)
