module Public.Pages.ResetPassword exposing (Model, Msg, init, subscriptions, update, view)

import ApiPub.InputObject
import ApiPub.Mutation
import ApiPub.Object
import ApiPub.Object.ResetPasswordResponse
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Notifications
import Public.Pages.Common as Common
import RemoteData
import Shared.Actions as Actions exposing (Actions)
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
    { form : Form
    , resetToken : String
    , response : GraphData Response
    , validationErrors : Maybe ( ValidationError, List ValidationError )
    }


newModel : String -> Model
newModel token =
    { form = newForm
    , resetToken = token
    , response = RemoteData.NotAsked
    , validationErrors = Nothing
    }


type alias Form =
    { password : String
    }


newForm =
    { password = ""
    }


asFormInModel : Model -> Form -> Model
asFormInModel model form =
    { model | form = form }


asPasswordInForm : Form -> String -> Form
asPasswordInForm form val =
    { form | password = val }


type alias ValidationError =
    ( Field, String )


type Field
    = Field_Password


type alias Returns =
    ( Model, Cmd Msg, Actions Msg )


type alias Response =
    { success : Bool
    , errors : List MutationError
    , jwt : Maybe String
    }


init : PublicContext -> String -> Returns
init context token =
    ( newModel token, Cmd.none, Actions.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type Msg
    = ChangePassword String
    | Submit
    | OnSubmitResponse (GraphResponse Response)


update : PublicContext -> Msg -> Model -> Returns
update context msg model =
    case msg of
        ChangePassword password ->
            ( password
                |> asPasswordInForm model.form
                |> asFormInModel model
            , Cmd.none
            , Actions.none
            )

        Submit ->
            case validateForm model.form of
                Err errors ->
                    ( { model
                        | validationErrors = Just errors
                      }
                    , Cmd.none
                    , Actions.none
                    )

                Ok input ->
                    ( { model
                        | response = RemoteData.Loading
                        , validationErrors = Nothing
                      }
                    , sendMutation context
                        model.form
                        model.resetToken
                    , Actions.none
                    )

        OnSubmitResponse result ->
            case result of
                Err e ->
                    ( { model | response = RemoteData.Failure e }
                    , Cmd.none
                    , Actions.addErrorNotification
                        "Something went wrong"
                    )

                Ok response ->
                    case response.jwt of
                        Just jwt ->
                            ( { model | response = RemoteData.Success response }
                            , Cmd.none
                            , Actions.startSession jwt
                            )

                        Nothing ->
                            ( { model | response = RemoteData.Success response }
                            , Cmd.none
                            , Actions.none
                            )


validateForm : Validator ValidationError Form Form
validateForm =
    validate Form
        |> verify .password (Forms.verifyPassword Field_Password)


view : PublicContext -> Model -> Html Msg
view context model =
    Common.layout
        context
        { containerAttributes = [ class "w-80" ]
        }
        [ Forms.form_ (formArgs model)
        ]


formArgs : Model -> Forms.Args Response Msg
formArgs model =
    { title = "Reset password"
    , intro = Nothing
    , submitContent = [ text "Reset" ]
    , fields = formFields model
    , onSubmit = Submit
    , response = model.response
    }


formFields model =
    [ Forms.set
        Field_Password
        "New password"
        (input
            [ class molecules.form.input
            , onInput ChangePassword
            , type_ "password"
            , value model.form.password
            ]
            []
        )
        model.validationErrors
    ]


sendMutation : PublicContext -> Form -> String -> Cmd Msg
sendMutation context form resetToken =
    sendPublicMutation
        context
        "reset-password"
        (resetMutation form resetToken)
        OnSubmitResponse


resetMutation : Form -> String -> SelectionSet Response RootMutation
resetMutation form resetToken =
    let
        input : ApiPub.InputObject.ResetPasswordInput
        input =
            { password = form.password
            , token = resetToken
            }
    in
    ApiPub.Mutation.selection identity
        |> with
            (ApiPub.Mutation.resetPassword
                { input = input }
                responseSelection
            )


responseSelection : SelectionSet Response ApiPub.Object.ResetPasswordResponse
responseSelection =
    ApiPub.Object.ResetPasswordResponse.selection Response
        |> with ApiPub.Object.ResetPasswordResponse.success
        |> with (ApiPub.Object.ResetPasswordResponse.errors mutationErrorPublicSelection)
        |> with ApiPub.Object.ResetPasswordResponse.jwt
