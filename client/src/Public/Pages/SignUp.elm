module Public.Pages.SignUp exposing (Model, Msg, init, subscriptions, update, view)

import ApiPub.Mutation
import ApiPub.Object
import ApiPub.Object.SignUpResponse
import Browser
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import RemoteData
import Shared.Context exposing (PublicContext)
import Shared.Css exposing (molecules)
import Shared.Flags as Flags
import Shared.GraphQl exposing (GraphData, GraphResponse, MutationError, mutationErrorPublicSelection, sendPublicMutation)
import Shared.Sessions as Sessions exposing (SignUp)
import UI.Flash as Flash
import UI.Forms as Forms


type alias Model =
    { flags : Flags.PublicFlags
    , signUp : SignUp
    , response : GraphData SignUpResponse
    }


initialModel : Flags.PublicFlags -> Model
initialModel flags =
    { flags = flags
    , signUp = Sessions.newSignUp
    , response = RemoteData.NotAsked
    }


type alias SignUpResponse =
    { success : Bool
    , errors : List MutationError
    , token : Maybe String
    }


asEmailInSignUp : SignUp -> String -> SignUp
asEmailInSignUp signUp email =
    { signUp | email = email }


asNameInSignUp : SignUp -> String -> SignUp
asNameInSignUp signUp name =
    { signUp | name = name }


asPasswordInSignUp : SignUp -> String -> SignUp
asPasswordInSignUp signUp password =
    { signUp | password = password }


asSignUpInModel : Model -> SignUp -> Model
asSignUpInModel model signUp =
    { model | signUp = signUp }


init : Flags.PublicFlags -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags, Cmd.none )


type Msg
    = ChangeEmail String
    | ChangeName String
    | ChangePassword String
    | Submit
    | OnSubmitResponse (GraphResponse SignUpResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        context : PublicContext
        context =
            { flags = model.flags
            }
    in
    case msg of
        ChangeEmail email ->
            ( email
                |> asEmailInSignUp model.signUp
                |> asSignUpInModel model
            , Cmd.none
            )

        ChangeName name ->
            ( name
                |> asNameInSignUp model.signUp
                |> asSignUpInModel model
            , Cmd.none
            )

        ChangePassword password ->
            ( password
                |> asPasswordInSignUp model.signUp
                |> asSignUpInModel model
            , Cmd.none
            )

        Submit ->
            ( { model | response = RemoteData.Loading }
            , sendCreateSignUpMutation context model.signUp
            )

        OnSubmitResponse result ->
            case result of
                Err e ->
                    Debug.log
                        (Debug.toString e)
                        ( { model | response = RemoteData.Failure e }, Cmd.none )

                Ok response ->
                    case response.token of
                        Just token ->
                            ( { model | response = RemoteData.Success response }
                            , Sessions.toJsUseToken token
                            )

                        Nothing ->
                            ( { model | response = RemoteData.Success response }
                            , Cmd.none
                            )


subscriptions model =
    Sub.none



-- VIEW
-- TODO add html validation


view : Model -> Html Msg
view model =
    div [ class "flex items-center justify-center pt-16" ]
        [ div []
            [ h1 []
                [ text "Sign up" ]
            , form
                [ class "bg-white shadow-md rounded p-8 mt-3", onSubmit Submit ]
                [ maybeErrors model
                , p []
                    [ label
                        [ class molecules.form.label ]
                        [ text "Name"
                        ]
                    , input
                        [ class molecules.form.input
                        , onInput ChangeName
                        , name "name"
                        ]
                        []
                    ]
                , p [ class "mt-6" ]
                    [ label
                        [ class molecules.form.label ]
                        [ text "Email"
                        ]
                    , input
                        [ class molecules.form.input
                        , type_ "email"
                        , onInput ChangeEmail
                        , name "email"
                        ]
                        []
                    ]
                , p [ class "mt-6" ]
                    [ label
                        [ class molecules.form.label ]
                        [ text "Password"
                        ]
                    , input
                        [ class molecules.form.input
                        , type_ "password"
                        , onInput ChangePassword
                        , name "password"
                        ]
                        []
                    ]
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
            text "..."

        _ ->
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
            Flash.error (Debug.toString err)

        _ ->
            text ""


links =
    p [ class "mt-6" ]
        [ text "Already signed up? "
        , a [ href "/a/sign-in" ] [ text "Sign in" ]
        ]



-- GraphQL data


sendCreateSignUpMutation : PublicContext -> SignUp -> Cmd Msg
sendCreateSignUpMutation context signUp =
    sendPublicMutation
        context
        "create-sign-up"
        (createSignUpMutation signUp)
        OnSubmitResponse


createSignUpMutation : SignUp -> SelectionSet SignUpResponse RootMutation
createSignUpMutation signUp =
    ApiPub.Mutation.selection identity
        |> with
            (ApiPub.Mutation.signUp
                { signUp = signUp }
                signUpResponseSelection
            )


signUpResponseSelection : SelectionSet SignUpResponse ApiPub.Object.SignUpResponse
signUpResponseSelection =
    ApiPub.Object.SignUpResponse.selection SignUpResponse
        |> with ApiPub.Object.SignUpResponse.success
        |> with (ApiPub.Object.SignUpResponse.errors mutationErrorPublicSelection)
        |> with ApiPub.Object.SignUpResponse.token