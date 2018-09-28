module Public.Pages.SignIn exposing (Model, Msg, init, subscriptions, update, view)

import ApiPub.Mutation
import ApiPub.Object
import ApiPub.Object.SignInResponse
import Browser
import Debug
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import RemoteData
import Shared.Actions as Actions
import Shared.Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl exposing (GraphData, GraphResponse, MutationError, mutationErrorPublicSelection, sendPublicMutation)
import Shared.Routes as Routes
import String.Verify
import UI.Flash as Flash
import UI.Forms as Forms
import UI.Icons as Icons
import UI.PublicLinks as PublicLinks
import Verify exposing (Validator, validate, verify)


type alias Model =
    { form : Form
    , response : GraphData SignInResponse
    , validationErrors : Maybe ( ValidationError, List ValidationError )
    }


newModel : Flags -> Model
newModel flags =
    { form = newForm
    , response = RemoteData.NotAsked
    , validationErrors = Nothing
    }


type alias Form =
    { usernameOrEmail : String
    , password : String
    }


newForm : Form
newForm =
    { usernameOrEmail = ""
    , password = ""
    }


type alias ValidationError =
    ( Field, String )


type Field
    = Field_UsernameOrEmail
    | Field_Password


type alias SignInResponse =
    { success : Bool
    , errors : List MutationError
    , jwt : Maybe String
    }


asUsernameInForm : Form -> String -> Form
asUsernameInForm signIn usernameOrEmail =
    { signIn | usernameOrEmail = usernameOrEmail }


asPasswordInForm : Form -> String -> Form
asPasswordInForm signIn password =
    { signIn | password = password }


asFormInModel : Model -> Form -> Model
asFormInModel model form =
    { model | form = form }


type alias Returns =
    ( Model, Cmd Msg, Actions.Actions Msg )


init : PublicContext -> Returns
init context =
    ( newModel context.flags
    , Cmd.none
    , Actions.none
    )


type Msg
    = ChangeUsernameOrEmail String
    | ChangePassword String
    | OnSubmitResponse (GraphResponse SignInResponse)
    | Submit


update : PublicContext -> Msg -> Model -> Returns
update context msg model =
    case msg of
        ChangeUsernameOrEmail usernameOrEmail ->
            ( usernameOrEmail
                |> asUsernameInForm model.form
                |> asFormInModel model
            , Cmd.none
            , Actions.none
            )

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
                    , sendCreateSignInMutation context model.form
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
        |> verify .usernameOrEmail verifyUsername
        |> verify .password verifyPassword


verifyUsername : Validator ValidationError String String
verifyUsername =
    String.Verify.notBlank ( Field_UsernameOrEmail, "Enter your username or email" )


verifyPassword : Validator ValidationError String String
verifyPassword =
    String.Verify.notBlank ( Field_Password, "Enter your password" )


subscriptions model =
    Sub.none



-- VIEW


view : PublicContext -> Model -> Html Msg
view context model =
    div [ class "flex items-center justify-center pt-16" ]
        [ div [ class "w-1/3" ]
            [ div [ class "bg-white shadow-md rounded p-8 mt-3" ]
                [ Forms.form_ (formArgs model)
                ]
            , PublicLinks.view context
            ]
        ]


formArgs : Model -> Forms.Args SignInResponse Msg
formArgs model =
    { title = "Sign in"
    , intro = Nothing
    , submitContent = [ text "Sign in" ]
    , fields = formFields model
    , onSubmit = Submit
    , response = model.response
    }


formFields model =
    [ Forms.set
        Field_UsernameOrEmail
        "Email"
        (input
            [ class molecules.form.input
            , onInput ChangeUsernameOrEmail
            , type_ "text"
            , value model.form.usernameOrEmail
            ]
            []
        )
        model.validationErrors
    , Forms.set
        Field_Password
        "Email"
        (input
            [ class molecules.form.input
            , onInput ChangePassword
            , type_ "password"
            , name "password"
            , value model.form.password
            ]
            []
        )
        model.validationErrors
    ]


maybeErrors : Model -> Html msg
maybeErrors model =
    case model.response of
        RemoteData.Success response ->
            Forms.mutationError
                "other"
                response.errors

        RemoteData.Failure err ->
            Flash.error "Error"

        _ ->
            text ""



-- GraphQl data


sendCreateSignInMutation : PublicContext -> Form -> Cmd Msg
sendCreateSignInMutation context signUp =
    sendPublicMutation
        context
        "create-sign-in"
        (createSignInMutation signUp)
        OnSubmitResponse


createSignInMutation : Form -> SelectionSet SignInResponse RootMutation
createSignInMutation signIn =
    ApiPub.Mutation.selection identity
        |> with
            (ApiPub.Mutation.signIn
                { signIn = signIn }
                signInResponseSelection
            )


signInResponseSelection : SelectionSet SignInResponse ApiPub.Object.SignInResponse
signInResponseSelection =
    ApiPub.Object.SignInResponse.selection SignInResponse
        |> with ApiPub.Object.SignInResponse.success
        |> with (ApiPub.Object.SignInResponse.errors mutationErrorPublicSelection)
        |> with ApiPub.Object.SignInResponse.jwt
