module SignIn exposing (main)

import Debug
import Html exposing (..)
import Html.Attributes exposing (class, href, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Shared.Flags as Flags
import Shared.Sessions as Sessions exposing (SignIn)


type alias Model =
    { flags : Flags.PublicFlags
    , signIn : SignIn
    , stage : Stage
    }


initialModel : Flags.PublicFlags -> Model
initialModel flags =
    { flags = flags
    , signIn = Sessions.newSignIn
    , stage = Stage_Initial
    }


type Stage
    = Stage_Initial
    | Stage_Processing


asEmailInSignIn : SignIn -> String -> SignIn
asEmailInSignIn signUp email =
    { signUp | email = email }


asPasswordInSignIn : SignIn -> String -> SignIn
asPasswordInSignIn signIn password =
    { signIn | password = password }


asSignInInModel : Model -> SignIn -> Model
asSignInInModel model signIn =
    { model | signIn = signIn }



-- type RemoteData
--     = NotAsked
--     | Loading
--     | Success Response
--     | Failed
-- type alias Response =
--     { error : Maybe String
--     , token : Maybe String
--     }


init : Flags.PublicFlags -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags, Cmd.none )


type Msg
    = ChangeEmail String
    | ChangePassword String
    | Submit


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
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
            ( { model | stage = Stage_Processing }
            , Cmd.none
            )



-- SubmitResponse (Ok response) ->
--     let
--         cmd =
--             case response.token of
--                 Just token ->
--                     Tokens.toJsUseToken token
--                 Nothing ->
--                     Cmd.none
--     in
--         ( { model | response = Success response }, cmd )
-- -- TODO log the error
-- SubmitResponse (Err err) ->
--     let
--         _ =
--             Debug.log "Err" err
--     in
--         ( { model | response = Failed }, Cmd.none )


-- request model =
--     Http.post "http://localhost:4010/sign-in" (requestBody model) responseDecoder


-- requestBody : Model -> Http.Body
-- requestBody model =
--     Encode.object
--         [ ( "email", Encode.string model.email )
--         , ( "password", Encode.string model.password )
--         ]
--         |> Http.jsonBody


-- responseDecoder : Decode.Decoder Response
-- responseDecoder =
--     Decode.map2 Response
--         (Decode.field "error" (Decode.nullable Decode.string))
--         (Decode.field "token" (Decode.nullable Decode.string))


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
                [ text "Sign In" ]
            , form
                [ class "bg-white shadow-md rounded p-8 mt-3", onSubmit Submit ]
                [ maybeError model
                , p []
                    [ label [ class labelClasses ]
                        [ text "Email"
                        ]
                    , input [ class inputClasses, onInput ChangeEmail ] []
                    ]
                , p [ class "mt-6" ]
                    [ label [ class labelClasses ]
                        [ text "Password"
                        ]
                    , input [ class inputClasses, type_ "password", onInput ChangePassword ] []
                    ]
                , p [ class "mt-6" ]
                    [ button [ class btnClasses ] [ text "Sign In" ]
                    ]
                , p [ class "mt-6" ]
                    [ a [ href "/sign-up" ] [ text "Sign Up" ]
                    ]
                ]
            ]
        ]


maybeError model =
    text ""
    -- case model.response of
    --     Success response ->
    --         case response.error of
    --             Just error ->
    --                 p [ class "mb-4 text-red" ]
    --                     [ text error
    --                     ]

    --             _ ->
    --                 text ""

    --     _ ->
    --         text ""


labelClasses =
    "blocktext-sm font-bold"


inputClasses =
    "appearance-none border w-full py-2 px-3 text-grey-darker leading-tight mt-1"


btnClasses =
    "bg-blue hover:bg-blue-dark text-white font-bold py-2 px-4 rounded"
