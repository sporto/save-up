module Public.Pages.SignUp exposing (Model, Msg, init, subscriptions, update, view)

import ApiPub.InputObject exposing (SignUp)
import ApiPub.Mutation
import ApiPub.Object
import ApiPub.Object.SignUpResponse
import Browser
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
import Shared.Sessions as Sessions
import String.Verify
import UI.Flash as Flash
import UI.Forms as Forms
import UI.Icons as Icons
import Verify exposing (Validator, validate, verify)


type alias Model =
    { form : SignUp
    , response : GraphData SignUpResponse
    , validationErrors : Maybe ( ValidationError, List ValidationError )
    }


type alias ValidationError =
    ( Field, String )


initialModel : Flags -> Model
initialModel flags =
    { form = Sessions.newSignUp
    , response = RemoteData.NotAsked
    , validationErrors = Nothing
    }


type alias SignUpResponse =
    { success : Bool
    , errors : List MutationError
    , jwt : Maybe String
    }


asSignUpInModel : Model -> SignUp -> Model
asSignUpInModel model form =
    { model | form = form }


type alias Returns =
    ( Model, Cmd Msg, Actions.Actions Msg )


init : Flags -> Returns
init flags =
    ( initialModel flags
    , Cmd.none
    , Actions.none
    )


type Msg
    = ChangeEmail String
    | ChangeName String
    | ChangeUsername String
    | ChangePassword String
    | Submit
    | OnSubmitResponse (GraphResponse SignUpResponse)


update : PublicContext -> Msg -> Model -> Returns
update context msg model =
    case msg of
        ChangeEmail email ->
            ( email
                |> Sessions.asEmailInSignUp model.form
                |> asSignUpInModel model
            , Cmd.none
            , Actions.none
            )

        ChangeName name ->
            ( name
                |> Sessions.asNameInSignUp model.form
                |> asSignUpInModel model
            , Cmd.none
            , Actions.none
            )

        ChangeUsername name ->
            ( name
                |> Sessions.asUsernameInSignUp model.form
                |> asSignUpInModel model
            , Cmd.none
            , Actions.none
            )

        ChangePassword password ->
            ( password
                |> Sessions.asPasswordInSignUp model.form
                |> asSignUpInModel model
            , Cmd.none
            , Actions.none
            )

        Submit ->
            case formValidator model.form of
                Err errors ->
                    ( { model
                        | validationErrors = Just errors
                      }
                    , Cmd.none
                    , Actions.none
                    )

                Ok input ->
                    ( { model | response = RemoteData.Loading }
                    , sendCreateSignUpMutation context input
                    , Actions.none
                    )

        OnSubmitResponse result ->
            case result of
                Err e ->
                    ( { model | response = RemoteData.Failure e }
                    , Cmd.none
                    , Actions.none
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


subscriptions model =
    Sub.none


type Field
    = Field_Name
    | Field_Email
    | Field_Username
    | Field_Password



-- VIEW
-- TODO add html validation


view : PublicContext -> Model -> Html Msg
view context model =
    div [ class "flex items-center justify-center pt-16" ]
        [ div [ class "w-1/3" ]
            [ h1 []
                [ text "Sign up" ]
            , form
                [ class "bg-white shadow-md rounded p-8 mt-3", onSubmit Submit ]
                [ maybeErrors model
                , Forms.set
                    Field_Name
                    "Name"
                    (input
                        [ class molecules.form.input
                        , onInput ChangeName
                        , name "name"
                        , value model.form.name
                        ]
                        []
                    )
                    model.validationErrors
                , Forms.set
                    Field_Username
                    "Username"
                    (input
                        [ class molecules.form.input
                        , onInput ChangeUsername
                        , name "username"
                        , value model.form.username
                        ]
                        []
                    )
                    model.validationErrors
                , Forms.set
                    Field_Email
                    "Email"
                    (input
                        [ class molecules.form.input
                        , onInput ChangeEmail
                        , name "email"
                        , value model.form.email
                        ]
                        []
                    )
                    model.validationErrors
                , Forms.set
                    Field_Password
                    "Password"
                    (input
                        [ class molecules.form.input
                        , type_ "password"
                        , onInput ChangePassword
                        , name "password"
                        , value model.form.password
                        ]
                        []
                    )
                    model.validationErrors
                , p [ class "mt-6" ]
                    [ submit model
                    ]
                ]
            , links
            ]
        ]


submit : Model -> Html Msg
submit model =
    case model.response of
        RemoteData.Loading ->
            Icons.spinner

        _ ->
            let
                isValid =
                    case formValidator model.form of
                        Ok _ ->
                            True

                        Err _ ->
                            False
            in
            button [ class molecules.form.submit ] [ text "Sign up" ]


maybeErrors : Model -> Html msg
maybeErrors model =
    case model.response of
        RemoteData.Success response ->
            if List.isEmpty response.errors then
                text ""

            else
                Forms.mutationError
                    "other"
                    response.errors

        RemoteData.Failure err ->
            Flash.error "Error"

        _ ->
            text ""


links =
    p [ class "mt-6" ]
        [ text "Already signed up? "
        , a [ href (Routes.pathFor Routes.routeForSignIn) ] [ text "Sign in" ]
        ]



-- Validations


formValidator : Validator ValidationError SignUp SignUp
formValidator =
    validate SignUp
        |> verify .name (Forms.verifyName Field_Name)
        |> verify .username (Forms.verifyUsername Field_Username)
        |> verify .email (Forms.verifyEmail Field_Email)
        |> verify .password (Forms.verifyPassword Field_Password)



-- GraphQL data


sendCreateSignUpMutation : PublicContext -> SignUp -> Cmd Msg
sendCreateSignUpMutation context form =
    sendPublicMutation
        context
        "create-sign-up"
        (createSignUpMutation form)
        OnSubmitResponse


createSignUpMutation : SignUp -> SelectionSet SignUpResponse RootMutation
createSignUpMutation form =
    ApiPub.Mutation.selection identity
        |> with
            (ApiPub.Mutation.signUp
                { signUp = form }
                formResponseSelection
            )


formResponseSelection : SelectionSet SignUpResponse ApiPub.Object.SignUpResponse
formResponseSelection =
    ApiPub.Object.SignUpResponse.selection SignUpResponse
        |> with ApiPub.Object.SignUpResponse.success
        |> with (ApiPub.Object.SignUpResponse.errors mutationErrorPublicSelection)
        |> with ApiPub.Object.SignUpResponse.jwt
