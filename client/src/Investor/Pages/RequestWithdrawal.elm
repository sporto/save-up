module Investor.Pages.RequestWithdrawal exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Api.InputObject
import Api.Mutation
import Api.Object
import Api.Object.RequestWithdrawalResponse
import Browser.Navigation as Nav
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Notifications
import RemoteData
import Shared.Actions as Actions exposing (Actions)
import Shared.Css as Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl as GraphQl exposing (GraphData, GraphResponse, MutationError, mutationErrorPublicSelection, sendPublicMutation)
import Shared.Routes as Routes
import String.Verify
import UI.Flash as Flash
import UI.Forms as Forms
import UI.Icons as Icons
import UI.PublicLinks as PublicLinks
import Verify exposing (Validator, validate, verify)


type alias ID =
    Int


type alias Model =
    { accountID : ID
    , form : Form
    , response : GraphData Response
    , validationErrors : Maybe ( ValidationError, List ValidationError )
    }


newModel : ID -> Model
newModel accountID =
    { accountID = accountID
    , form = newForm
    , response = RemoteData.NotAsked
    , validationErrors = Nothing
    }


type alias Form =
    { amount : String }


type alias VerifiedForm =
    { amount : Int
    }


newForm : Form
newForm =
    { amount = "" }


asAmountInForm form amount =
    { form | amount = amount }


asFormInModel model form =
    { model | form = form }


type alias ValidationError =
    ( Field, String )


type Field
    = Field_Amount


type Msg
    = NoOp
    | OnResponse (GraphResponse Response)
    | ChangeAmount String
    | Submit


type alias Returns =
    ( Model, Cmd Msg, Actions Msg )


init : Context -> ID -> Returns
init context accountID =
    ( newModel accountID, Cmd.none, Actions.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Context -> Msg -> Model -> Returns
update context msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none, Actions.none )

        ChangeAmount amount ->
            ( amount
                |> asAmountInForm model.form
                |> asFormInModel model
            , Cmd.none
            , Actions.none
            )

        OnResponse result ->
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
                                    |> asAmountInForm model.form
                          }
                        , Nav.pushUrl context.navKey (Routes.pathFor <| Routes.routeForInvestorHome)
                        , Actions.addSuccessNotification
                            "Withdrawal requested"
                        )

                    else
                        ( { model | response = RemoteData.Success response }
                        , Cmd.none
                        , Actions.none
                        )

        Submit ->
            case validateForm model.form of
                Ok form ->
                    ( { model
                        | response = RemoteData.Loading
                        , validationErrors = Nothing
                      }
                    , requestWithdrawCmd
                        context
                        model.accountID
                        (form.amount * 100)
                    , Actions.none
                    )

                Err errors ->
                    ( { model | validationErrors = Just errors }
                    , Cmd.none
                    , Actions.none
                    )


validateForm : Validator ValidationError Form VerifiedForm
validateForm =
    validate VerifiedForm
        |> verify .amount (Forms.validateAmount ( Field_Amount, "Invalid amount" ))


view : Context -> Model -> Html Msg
view context model =
    div [ class molecules.page.container, class "flex justify-center" ]
        [ div [ style "width" "24rem" ]
            [ Forms.form_ (formArgsWithdraw model) ]
        ]


formArgsWithdraw : Model -> Forms.Args Response Msg
formArgsWithdraw model =
    { title = "Request a withdrawal"
    , intro = Nothing
    , submitContent = submitContentWithdraw
    , fields = formFieldsWithdraw model
    , onSubmit = Submit
    , response = model.response
    }


submitContentWithdraw =
    [ span [ class "mr-2" ] [ Icons.withdraw ]
    , text "Request"
    ]


formFieldsWithdraw : Model -> List (Html Msg)
formFieldsWithdraw model =
    [ Forms.set
        Field_Amount
        "Amount"
        (input
            [ class molecules.form.input
            , onInput ChangeAmount
            , type_ "number"
            , name "amount"
            , value model.form.amount
            ]
            []
        )
        model.validationErrors
    ]


type alias Response =
    { success : Bool
    , errors : List MutationError
    }


requestWithdrawCmd : Context -> ID -> Int -> Cmd Msg
requestWithdrawCmd context accountID cents =
    GraphQl.sendMutation
        context
        "request-withdrawal"
        (requestWithdrawMutation accountID cents)
        OnResponse


requestWithdrawMutation : ID -> Int -> SelectionSet Response RootMutation
requestWithdrawMutation accountID cents =
    let
        input : Api.InputObject.RequestWithdrawalInput
        input =
            { accountId = accountID, cents = cents }
    in
    SelectionSet.succeed identity
        |> with
            (Api.Mutation.requestWithdraw
                { input = input }
                withdrawResponseSelection
            )


withdrawResponseSelection : SelectionSet Response Api.Object.RequestWithdrawalResponse
withdrawResponseSelection =
    SelectionSet.succeed Response
        |> with Api.Object.RequestWithdrawalResponse.success
        |> with (Api.Object.RequestWithdrawalResponse.errors GraphQl.mutationErrorSelection)
