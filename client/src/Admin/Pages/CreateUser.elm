module Admin.Pages.CreateUser exposing (Model, Msg)

import Api.InputObject exposing (CreateUserInput)
import Api.Mutation
import Api.Object
import Api.Object.CreateUserResponse
import Api.Object.User
import Graphql.Field as Field
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, src, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import RemoteData
import Shared.Actions as Actions
import Shared.Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl as GraphQl exposing (GraphData, GraphResponse, MutationError, mutationErrorSelection, sendMutation)
import Shared.Routes as Routes
import Time exposing (Posix)
import UI.Chart as Chart
import UI.Empty as Empty
import UI.Flash as Flash
import UI.Icons as Icons
import Verify exposing (Validator, validate, verify)


type Msg
    = ChangeEmail String
    | ChangeName String
    | ChangePassword String
    | ChangeUsername String
    | Submit
    | OnResponse (GraphResponse CreateUserResponse)


type alias Model =
    { form : Form
    , response : GraphData CreateUserResponse
    }


newModel : Model
newModel =
    { form = newForm
    , response = RemoteData.NotAsked
    }


type alias Form =
    { email : String, username : String, name : String, password : String }


newForm : Form
newForm =
    { email = ""
    , username = ""
    , name = ""
    , password = ""
    }


type alias Returns =
    ( Model, Cmd Msg, Actions.Actions Msg )


init : Returns
init =
    ( newModel, Cmd.none, Actions.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


justModel model =
    ( model, Cmd.none, Actions.none )


update : Context -> Msg -> Model -> Returns
update context msg model =
    let
        form =
            model.form
    in
    case msg of
        ChangeEmail email ->
            { model | form = { form | email = email } }
                |> justModel

        ChangeName name ->
            { model | form = { form | name = name } }
                |> justModel

        ChangeUsername username ->
            { model | form = { form | username = username } }
                |> justModel

        ChangePassword password ->
            { model | form = { form | password = password } }
                |> justModel

        Submit ->
            ( { model | response = RemoteData.Loading }
            , createMutationCmd context model.form
            , Actions.none
            )

        OnResponse result ->
            case result of
                Err e ->
                    ( { model | response = RemoteData.Failure e }
                    , Cmd.none
                    , Actions.none
                    )

                Ok response ->
                    if response.success then
                        ( { model
                            | response = RemoteData.Success response
                            , email = ""
                          }
                        , Cmd.none
                        , Actions.none
                        )

                    else
                        ( { model | response = RemoteData.Success response }
                        , Cmd.none
                        , Actions.none
                        )


view : Context -> Model -> Html Msg
view context model =
    section [ class molecules.page.container, class "flex justify-center" ]
        [ div [ style "width" "24rem" ]
            [ h1 [ class molecules.page.title ] [ text "Create user" ]
            , form [ class "mt-2", onSubmit Submit ]
                [ flash model
                , p [ class molecules.form.fieldset ]
                    [ label
                        [ class molecules.form.label
                        ]
                        [ text "Name" ]
                    , input
                        [ class molecules.form.input
                        , type_ "text"
                        , name "name"
                        , value model.form.name
                        , onInput ChangeName
                        ]
                        []
                    ]
                , p [ class molecules.form.fieldset ]
                    [ label
                        [ class molecules.form.label
                        ]
                        [ text "Username" ]
                    , input
                        [ class molecules.form.input
                        , type_ "text"
                        , name "username"
                        , value model.form.username
                        , onInput ChangeUsername
                        ]
                        []
                    ]
                , p [ class molecules.form.fieldset ]
                    [ label
                        [ class molecules.form.label
                        ]
                        [ text "Email (optional)" ]
                    , input
                        [ class molecules.form.input
                        , type_ "email"
                        , name "email"
                        , value model.form.email
                        , onInput ChangeEmail
                        ]
                        []
                    ]
                , p [ class molecules.form.fieldset ]
                    [ label
                        [ class molecules.form.label
                        ]
                        [ text "Password" ]
                    , input
                        [ class molecules.form.input
                        , type_ "password"
                        , name "password"
                        , value model.form.password
                        , onInput ChangePassword
                        ]
                        []
                    ]
                , p [ class molecules.form.actions ]
                    [ submit model
                    ]
                ]
            ]
        ]


submit : Model -> Html Msg
submit model =
    case model.response of
        RemoteData.Loading ->
            Icons.spinner

        _ ->
            button [ class molecules.form.submit ] [ i [ class "fas fa-envelope mr-2" ] [], text "Create" ]


flash : Model -> Html msg
flash model =
    case model.response of
        RemoteData.Success response ->
            if response.success then
                Flash.success
                    "User created"

            else
                text ""

        RemoteData.Failure e ->
            Flash.error
                "Something went wrong"

        _ ->
            text ""



-- GraphQl


type alias CreateUserResponse =
    { success : Bool
    , errors : List MutationError
    , user : Maybe User
    }


type alias User =
    { name : String
    }


createMutationCmd : Context -> CreateUserInput -> Cmd Msg
createMutationCmd context input =
    sendMutation
        context
        "create-user"
        (createMutation input)
        OnResponse


createMutation : CreateUserInput -> SelectionSet CreateUserResponse RootMutation
createMutation input =
    Api.Mutation.selection identity
        |> with
            (Api.Mutation.createUser
                { input = input }
                createUserResponseSelection
            )


createUserResponseSelection : SelectionSet CreateUserResponse Api.Object.CreateUserResponse
createUserResponseSelection =
    Api.Object.CreateUserResponse.selection CreateUserResponse
        |> with Api.Object.CreateUserResponse.success
        |> with (Api.Object.CreateUserResponse.errors mutationErrorSelection)
        |> with (Api.Object.CreateUserResponse.user userSelection)


userSelection : SelectionSet User Api.Object.User
userSelection =
    Api.Object.User.selection User
        |> with Api.Object.User.name
