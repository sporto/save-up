module SignUp exposing (main)

import Debug
import Html exposing (..)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import RemoteData
import Shared.Flags as Flags
import Shared.Sessions as Sessions exposing (SignUp)
import Shared.GraphQl exposing (GraphData, MutationError)


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
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
            , Sessions.toJsSignUp model.signUp
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
                [ text "Sign Up" ]
            , form
                [ class "bg-white shadow-md rounded p-8 mt-3", onSubmit Submit ]
                [ maybeErrors model
                , p []
                    [ label [ class labelClasses ]
                        [ text "Name"
                        ]
                    , input [ class inputClasses, onInput ChangeName ] []
                    ]
                , p [ class "mt-6" ]
                    [ label [ class labelClasses ]
                        [ text "Email"
                        ]
                    , input [ class inputClasses, type_ "email", onInput ChangeEmail ] []
                    ]
                , p [ class "mt-6" ]
                    [ label [ class labelClasses ]
                        [ text "Password"
                        ]
                    , input [ class inputClasses, type_ "password", onInput ChangePassword ] []
                    ]
                , p [ class "mt-6" ]
                    [ submit model
                    ]
                ]
            ]
        ]


submit : Model -> Html Msg
submit model =
    case model.response of
        RemoteData.Loading ->
            text "..."

        _ ->
            button [ class btnClasses ] [ text "Sign In" ]


maybeErrors model =
    case model.response of
        RemoteData.Success response ->
            if List.isEmpty response.errors then
                text ""
            else
                p [ class "mb-4 text-red" ]
                    [ text (toString response.errors)
                    ]

        _ ->
            text ""


labelClasses =
    "blocktext-sm font-bold"


inputClasses =
    "appearance-none border w-full py-2 px-3 text-grey-darker leading-tight mt-1"


btnClasses =
    "bg-blue hover:bg-blue-dark text-white font-bold py-2 px-4 rounded"
