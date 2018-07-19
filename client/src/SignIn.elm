module SignIn exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick, onSubmit)
import Http
import Json.Decode as Decode
import Json.Encode as Encode


type alias Flags =
    ()


type alias Model =
    { email : String
    , password : String
    }


initialModel : Model
initialModel =
    { email = ""
    , password = ""
    }


init flags =
    ( initialModel, Cmd.none )


type Msg
    = ChangeEmail String
    | ChangePassword String
    | Submit
    | SubmitResponse (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeEmail email ->
            ( { model | email = email }, Cmd.none )

        ChangePassword password ->
            ( { model | password = password }, Cmd.none )

        Submit ->
            ( model
            , Http.send
                SubmitResponse
                (request model)
            )

        -- TODO store token and redirect
        SubmitResponse (Ok _) ->
            ( model, Cmd.none )

        -- TODO log the error
        SubmitResponse (Err _) ->
            ( model, Cmd.none )



-- TODO use flags for api


request model =
    Http.post "http://localhost:4010/sign-in" (requestBody model) responseDecoder


requestBody : Model -> Http.Body
requestBody model =
    Encode.object
        [ ( "email", Encode.string model.email )
        , ( "password", Encode.string model.password )
        ]
        |> Http.jsonBody


responseDecoder =
    (Decode.string)


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
-- TODO show errors

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
                    [ p []
                        [ label [ class labelClasses ]
                            [ text "Email"
                            ]
                        , input [ class inputClasses ] []
                        ]
                    , p [ class "mt-6" ]
                        [ label [ class labelClasses ]
                            [ text "Password"
                            ]
                        , input [ class inputClasses, type_ "password" ] []
                        ]
                    , p [ class "mt-6" ]
                        [ button [ class btnClasses ] [ text "Sign In" ]
                        ]
                    ]
                ]
            ]
        ]
    }


labelClasses =
    "blocktext-sm font-bold"


inputClasses =
    "appearance-none border w-full py-2 px-3 text-grey-darker leading-tight mt-1"


btnClasses =
    "bg-blue hover:bg-blue-dark text-white font-bold py-2 px-4 rounded"
