module Public.Pages.RequestPassword exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import ApiPub.InputObject exposing (RequestPasswordResetInput)
import ApiPub.Mutation
import ApiPub.Object
import ApiPub.Object.RequestPasswordResetResponse
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Notifications
import Public.Pages.Common as Common
import RemoteData
import Shared.Actions as Actions
import Shared.Css as Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl exposing (GraphData, GraphResponse, MutationError, mutationErrorPublicSelection, sendPublicMutation)
import String.Verify
import UI.Flash as Flash
import UI.Forms as Forms
import UI.Icons as Icons
import UI.PublicLinks as PublicLinks
import Verify exposing (Validator, validate, verify)


type alias Model =
    { form : RequestPasswordResetInput
    , response : GraphData RequestPasswordResetResponse
    , validationErrors : Maybe ( ValidationError, List ValidationError )
    }


initialModel : Model
initialModel =
    { form =
        { usernameOrEmail = ""
        }
    , response = RemoteData.NotAsked
    , validationErrors = Nothing
    }


asFormInModel : Model -> RequestPasswordResetInput -> Model
asFormInModel model form =
    { model | form = form }


asUsernameInForm : RequestPasswordResetInput -> String -> RequestPasswordResetInput
asUsernameInForm form val =
    { form | usernameOrEmail = val }


type alias RequestPasswordResetResponse =
    { success : Bool
    , errors : List MutationError
    }


type Field
    = Field_Username


type alias ValidationError =
    ( Field, String )


type alias Returns =
    ( Model, Cmd Msg, Actions.Actions Msg )


init : PublicContext -> Returns
init context =
    ( initialModel
    , Cmd.none
    , Actions.none
    )


type Msg
    = ChangeUsername String
    | Submit
    | OnSubmitResponse (GraphResponse RequestPasswordResetResponse)


update : PublicContext -> Msg -> Model -> Returns
update context msg model =
    case msg of
        ChangeUsername name ->
            ( name
                |> asUsernameInForm model.form
                |> asFormInModel model
            , Cmd.none
            , Actions.none
            )

        Submit ->
            case validateForm model.form of
                Ok form ->
                    ( { model | response = RemoteData.Loading }
                    , sendMutation context form
                    , Actions.none
                    )

                Err errors ->
                    ( { model | validationErrors = Just errors }
                    , Cmd.none
                    , Actions.none
                    )

        OnSubmitResponse result ->
            case result of
                Err e ->
                    ( { model
                        | response = RemoteData.Failure e
                      }
                    , Cmd.none
                    , Actions.addErrorNotification failedResponseMessage
                    )

                Ok response ->
                    if response.success then
                        ( { model | response = RemoteData.Success response }
                        , Cmd.none
                        , Actions.addSuccessNotification "Reset link sent, please check your email"
                        )

                    else
                        ( { model | response = RemoteData.Success response }
                        , Cmd.none
                        , Actions.addErrorNotification failedResponseMessage
                        )


failedResponseMessage =
    "Failed to request password reset"


subscriptions model =
    Sub.none


view : PublicContext -> Model -> Html Msg
view context model =
    Common.layout
        context
        { containerAttributes = [ class "w-80" ]
        }
        [ Forms.form_ (formArgs model)
        ]


formArgs : Model -> Forms.Args RequestPasswordResetResponse Msg
formArgs model =
    { title = "Reset your password"
    , intro = Nothing
    , submitContent = [ text "Request" ]
    , fields = formFields model
    , onSubmit = Submit
    , response = model.response
    }


formFields model =
    [ Forms.set
        Field_Username
        "Username or email"
        (input
            [ class molecules.form.input
            , onInput ChangeUsername
            , value model.form.usernameOrEmail
            ]
            []
        )
        model.validationErrors
    ]



-- Validation


validateForm =
    validate RequestPasswordResetInput
        |> verify .usernameOrEmail (String.Verify.notBlank ( Field_Username, "Enter a username or email" ))



-- GraphQl data


sendMutation : PublicContext -> RequestPasswordResetInput -> Cmd Msg
sendMutation context input =
    sendPublicMutation
        context
        "request-password-reset"
        (mutation input)
        OnSubmitResponse


mutation : RequestPasswordResetInput -> SelectionSet RequestPasswordResetResponse RootMutation
mutation input =
    SelectionSet.succeed identity
        |> with
            (ApiPub.Mutation.requestPasswordReset
                { input = input }
                responseSelection
            )


responseSelection : SelectionSet RequestPasswordResetResponse ApiPub.Object.RequestPasswordResetResponse
responseSelection =
    SelectionSet.succeed
        RequestPasswordResetResponse
        |> with ApiPub.Object.RequestPasswordResetResponse.success
        |> with (ApiPub.Object.RequestPasswordResetResponse.errors mutationErrorPublicSelection)
