module Admin.Pages.Account exposing (Model, Msg, init, subscriptions, update, view)

import Admin.Routes as Routes
import Api.Mutation
import Api.Object
import Api.Object.DepositResponse
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, src, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import RemoteData
import Shared.Context exposing (Context)
import Shared.Css exposing (molecules)
import Shared.GraphQl exposing (GraphData, GraphResponse, MutationError, mutationErrorSelection, sendMutation)
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
    = SubPage_Top
    | SubPage_Deposit DepositModel
    | SubPage_Withdraw


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


type DepositMsg
    = OnDepositResponse (GraphResponse DepositResponse)
    | ChangeDepositAmount String
    | SubmitDeposit


init : Context -> ID -> Routes.RouteAccount -> ( Model, Cmd Msg )
init context accountID route =
    let
        subPage =
            case route of
                Routes.RouteAccount_Top ->
                    SubPage_Top

                Routes.RouteAccount_Deposit ->
                    SubPage_Deposit newDepositModel

                Routes.RouteAccount_Withdraw ->
                    SubPage_Withdraw
    in
    ( newModel accountID subPage, getData context )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Context -> Msg -> Model -> ( Model, Cmd Msg )
update context msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

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
                    ( { model | subPage = SubPage_Deposit nextDepositModel }, Cmd.map Msg_Desposit newCmd )

                _ ->
                    ( model, Cmd.none )


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
            Routes.routeForAccountShow model.accountID

        routeDeposit =
            Routes.routeForAccountDeposit model.accountID

        routeWithdraw =
            Routes.routeForAccountWithdraw model.accountID
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
        , class "text-white mr-4 no-underline"
        ]
        [ text label ]


currentPage : Context -> Model -> Html Msg
currentPage context model =
    case model.subPage of
        SubPage_Top ->
            div [ class molecules.page.container ]
                [ img [ src "https://via.placeholder.com/600x320" ] []
                ]

        SubPage_Deposit depositModel ->
            deposit
                context
                depositModel
                |> map Msg_Desposit

        SubPage_Withdraw ->
            div [ class molecules.page.container ]
                [ h1 [ class molecules.page.title ] [ text "Make a withdrawal" ]
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


getData context =
    Cmd.none


type alias DepositResponse =
    { success : Bool
    , errors : List MutationError
    }


depositMutationCmd : Context -> ID -> Int -> Cmd DepositMsg
depositMutationCmd context accountID cents =
    sendMutation
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
        |> with (Api.Object.DepositResponse.errors mutationErrorSelection)
