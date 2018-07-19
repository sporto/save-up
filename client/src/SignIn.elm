module SignIn exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)


type alias Flags =
    ()


type alias Model =
    { count : Int }


initialModel : Model
initialModel =
    { count = 0 }


init flags =
    ( initialModel, Cmd.none )


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | count = model.count + 1 }, Cmd.none )

        Decrement ->
            ( { model | count = model.count - 1 }, Cmd.none )


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


view : Model -> Browser.Document Msg
view model =
    { title = "KIC Admin"
    , body =
        [ div [ class "flex items-center justify-center pt-16" ]
            [ div []
                [ h1 []
                    [ text "Sign In" ]
                , form
                    [ class "bg-white shadow-md rounded p-8 mt-3" ]
                    [ p [  ]
                        [ label [ class labelClasses ]
                            [ text "Email"
                            ]
                        , input [ class inputClasses ] []
                        ]
                    , p [ class "mt-6" ]
                        [ label [ class labelClasses ]
                            [ text "Password"
                            ]
                        , input [ class inputClasses ] []
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
