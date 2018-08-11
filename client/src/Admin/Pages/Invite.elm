module Admin.Pages.Invite exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href, name, value, type_)
import Shared.Css exposing (molecules)


type Msg
    = ChangeEmail String


type alias Model =
    { email : String }


newModel : Model
newModel =
    { email = ""
    }


init : ( Model, Cmd Msg )
init =
    ( newModel, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeEmail email ->
            ( { model | email = email }, Cmd.none )


view : Model -> Html Msg
view model =
    section []
        [ h1 [] [ text "Invite" ]
        , form []
            [ p []
                [ label
                    [ class molecules.form.label
                    ]
                    [ text "Email" ]
                , input
                    [ class molecules.form.input
                    , type_ "email"
                    , name "email"
                    , value model.email
                    ]
                    []
                ]
            ]
        ]
