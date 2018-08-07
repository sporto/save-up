module SignUp exposing (main)

import Api.Mutation
import Api.Object
import Api.Object.SignUpResponse
import Graphqelm.Operation exposing (RootQuery, RootMutation)
import Graphqelm.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import RemoteData
import Shared.Context exposing (PublicContext)
import Shared.Flags as Flags
import Shared.GraphQl exposing (GraphResponse, GraphData, MutationError, mutationErrorSelection, sendPublicMutation)
import Shared.Sessions as Sessions exposing (SignUp)
import UI.Flash as Flash


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
                [ text "Sign up" ]
            , form
                [ class "bg-white shadow-md rounded p-8 mt-3", onSubmit Submit ]
                [ maybeErrors model
                , p []
                    [ label
                        [ class labelClasses ]
                        [ text "Name"
                        ]
                    , input
                        [ class inputClasses
                        , onInput ChangeName
                        , name "name"
                        ]
                        []
                    ]
                , p [ class "mt-6" ]
                    [ label
                        [ class labelClasses ]
                        [ text "Email"
                        ]
                    , input
                        [ class inputClasses
                        , type_ "email"
                        , onInput ChangeEmail
                        , name "email"
                        ]
                        []
                    ]
                , p [ class "mt-6" ]
                    [ label
                        [ class labelClasses ]
                        [ text "Password"
                        ]
                    , input
                        [ class inputClasses
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
            button [ class btnClasses ] [ text "Sign up" ]


maybeErrors : Model -> Html msg
maybeErrors model =
    case model.response of
        RemoteData.Success response ->
            if List.isEmpty response.errors then
                text ""
            else
                response.errors
                    |> List.concatMap .messages
                    |> String.join ", "
                    |> Flash.error

        RemoteData.Failure err ->
            Flash.error (toString err)

        _ ->
            text ""


labelClasses =
    "blocktext-sm font-bold"


inputClasses =
    "appearance-none border w-full py-2 px-3 text-grey-darker leading-tight mt-1"


btnClasses =
    "bg-blue hover:bg-blue-dark text-white font-bold py-2 px-4 rounded"


links =
    p [ class "mt-6"]
        [ text "Already signed up? "
        , a [ href "/sign-in" ] [ text "sign in" ]
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
    Api.Mutation.selection identity
        |> with
            (Api.Mutation.signUp
                { signUp = signUp }
                signUpResponseSelection
            )


signUpResponseSelection : SelectionSet SignUpResponse Api.Object.SignUpResponse
signUpResponseSelection =
    Api.Object.SignUpResponse.selection SignUpResponse
        |> with (Api.Object.SignUpResponse.success)
        |> with (Api.Object.SignUpResponse.errors mutationErrorSelection)
        |> with (Api.Object.SignUpResponse.token)
