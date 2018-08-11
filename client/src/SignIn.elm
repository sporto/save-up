module SignIn exposing (main)

import Api.Mutation
import Api.Object
import Api.Object.SignInResponse
import Graphqelm.Operation exposing (RootQuery, RootMutation)
import Graphqelm.SelectionSet exposing (SelectionSet, with)
import Debug
import Html exposing (..)
import Html.Attributes exposing (class, href, name, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import RemoteData
import Shared.Css exposing (molecules)
import Shared.Context exposing (PublicContext)
import Shared.Flags as Flags
import Shared.GraphQl exposing (GraphResponse, GraphData, MutationError, mutationErrorSelection, sendPublicMutation)
import Shared.Sessions as Sessions exposing (SignIn)
import UI.Flash as Flash
import UI.Forms as Forms


type alias Model =
    { flags : Flags.PublicFlags
    , signIn : SignIn
    , response : GraphData SignInResponse
    }


initialModel : Flags.PublicFlags -> Model
initialModel flags =
    { flags = flags
    , signIn = Sessions.newSignIn
    , response = RemoteData.NotAsked
    }


type alias SignInResponse =
    { success : Bool
    , errors : List MutationError
    , token : Maybe String
    }


asEmailInSignIn : SignIn -> String -> SignIn
asEmailInSignIn signUp email =
    { signUp | email = email }


asPasswordInSignIn : SignIn -> String -> SignIn
asPasswordInSignIn signIn password =
    { signIn | password = password }


asSignInInModel : Model -> SignIn -> Model
asSignInInModel model signIn =
    { model | signIn = signIn }


init : Flags.PublicFlags -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags, Cmd.none )


type Msg
    = ChangeEmail String
    | ChangePassword String
    | Submit
    | OnSubmitResponse (GraphResponse SignInResponse)


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
                    |> asEmailInSignIn model.signIn
                    |> asSignInInModel model
                , Cmd.none
                )

            ChangePassword password ->
                ( password
                    |> asPasswordInSignIn model.signIn
                    |> asSignInInModel model
                , Cmd.none
                )

            Submit ->
                ( { model | response = RemoteData.Loading }
                , sendCreateSignInMutation context model.signIn
                )

            OnSubmitResponse result ->
                case result of
                    Err e ->
                        Debug.log
                            (toString e)
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


main : Program Flags.PublicFlags Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- VIEW
-- TODO add html validation


view : Model -> Html Msg
view model =
    div [ class "flex items-center justify-center pt-16" ]
        [ div []
            [ h1 []
                [ text "Sign in" ]
            , form
                [ class "bg-white shadow-md rounded p-8 mt-3", onSubmit Submit ]
                [ maybeErrors model
                , p []
                    [ label [ class molecules.form.label ]
                        [ text "Email"
                        ]
                    , input
                        [ class molecules.form.input
                        , type_ "email"
                        , name "email"
                        , onInput ChangeEmail
                        ]
                        []
                    ]
                , p [ class "mt-6" ]
                    [ label [ class molecules.form.label ]
                        [ text "Password"
                        ]
                    , input
                        [ class molecules.form.input
                        , type_ "password"
                        , name "password"
                        , onInput ChangePassword
                        ]
                        []
                    ]
                , p [ class "mt-6" ] [ submit model ]
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
            button [ class molecules.form.submit ] [ text "Sign in" ]


links =
    p [ class "mt-6" ]
        [ a [ href "/sign-up" ] [ text "Sign up" ]
        ]


maybeErrors : Model -> Html msg
maybeErrors model =
    case model.response of
        RemoteData.Success response ->
            Forms.mutationError
                "other"
                response.errors

        RemoteData.Failure err ->
            Flash.error (toString err)

        _ ->
            text ""



-- GraphQl data


sendCreateSignInMutation : PublicContext -> SignIn -> Cmd Msg
sendCreateSignInMutation context signUp =
    sendPublicMutation
        context
        "create-sign-in"
        (createSignInMutation signUp)
        OnSubmitResponse


createSignInMutation : SignIn -> SelectionSet SignInResponse RootMutation
createSignInMutation signIn =
    Api.Mutation.selection identity
        |> with
            (Api.Mutation.signIn
                { signIn = signIn }
                signInResponseSelection
            )


signInResponseSelection : SelectionSet SignInResponse Api.Object.SignInResponse
signInResponseSelection =
    Api.Object.SignInResponse.selection SignInResponse
        |> with (Api.Object.SignInResponse.success)
        |> with (Api.Object.SignInResponse.errors mutationErrorSelection)
        |> with (Api.Object.SignInResponse.token)
