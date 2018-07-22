module SignUp exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Shared.Tokens as Tokens


type alias Flags =
    ()


type alias Model =
    { email : String
    , name : String
    , password : String
    , timezone : String
    , response : RemoteData
    }


initialModel : Model
initialModel =
    { email = ""
    , name = ""
    , password = ""
    , timezone = "Australia/Melbourne"
    , response = NotAsked
    }


type RemoteData
    = NotAsked
    | Loading
    | Success Response
    | Failed


type alias Response =
    { error : Maybe String
    , token : Maybe String
    }


init flags =
    ( initialModel, Cmd.none )


type Msg
    = ChangeEmail String
    | ChangeName String
    | ChangePassword String
    | Submit
    | SubmitResponse (Result Http.Error Response)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeEmail email ->
            ( { model | email = email }, Cmd.none )

        ChangeName name ->
            ( { model | name = name }, Cmd.none )

        ChangePassword password ->
            ( { model | password = password }, Cmd.none )

        Submit ->
            ( { model | response = Loading }
            , Http.send
                SubmitResponse
                (request model)
            )

        SubmitResponse (Ok response) ->
            let
                cmd =
                    case response.token of
                        Just token ->
                            Tokens.toJsUseToken token

                        Nothing ->
                            Cmd.none
            in
                ( { model | response = Success response }, cmd )

        -- TODO log the error
        SubmitResponse (Err err) ->
            let
                _ =
                    Debug.log "Err" err
            in
                ( { model | response = Failed }, Cmd.none )



-- TODO use flags for api


request model =
    Http.post "http://localhost:4010/sign-up" (requestBody model) responseDecoder


requestBody : Model -> Http.Body
requestBody model =
    Encode.object
        [ ( "email", Encode.string model.email )
        , ( "name", Encode.string model.name )
        , ( "password", Encode.string model.password )
        , ( "timezone", Encode.string model.timezone )
        ]
        |> Http.jsonBody


responseDecoder : Decode.Decoder Response
responseDecoder =
    Decode.map2 Response
        (Decode.field "error" (Decode.nullable Decode.string))
        (Decode.field "token" (Decode.nullable Decode.string))


subscriptions model =
    Sub.none


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- VIEW
-- TODO add html validation


view : Model -> Browser.Document Msg
view model =
    { title = "KIC Admin"
    , body =
        [ div [ class "flex items-center justify-center pt-16" ]
            [ div []
                [ h1 []
                    [ text "Sign In" ]
                , form
                    [ class "bg-white shadow-md rounded p-8 mt-3", onSubmit Submit ]
                    [ maybeError model
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
                    ]
                ]
            ]
        ]
    }


maybeError model =
    case model.response of
        Success response ->
            case response.error of
                Just error ->
                    p [ class "mb-4 text-red" ]
                        [ text error
                        ]

                _ ->
                    text ""

        _ ->
            text ""


labelClasses =
    "blocktext-sm font-bold"


inputClasses =
    "appearance-none border w-full py-2 px-3 text-grey-darker leading-tight mt-1"


btnClasses =
    "bg-blue hover:bg-blue-dark text-white font-bold py-2 px-4 rounded"
