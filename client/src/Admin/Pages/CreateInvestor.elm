module Admin.Pages.CreateInvestor exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Api.InputObject exposing (CreateUserInput)
import Api.Mutation
import Api.Object
import Api.Object.CreateUserResponse
import Api.Object.User
import Browser.Navigation as Nav
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.OptionalArgument as OptionalArgument
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, src, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Notifications
import Regex
import RemoteData
import Shared.Actions as Actions
import Shared.Css as Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl as GraphQl exposing (GraphData, GraphResponse, MutationError, mutationErrorSelection, sendMutation)
import Shared.Routes as Routes
import String.Verify
import Time exposing (Posix)
import UI.ChartV2 as Chart
import UI.Empty as Empty
import UI.Flash as Flash
import UI.Forms as Forms
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
    , validationErrors : Maybe ( ValidationError, List ValidationError )
    }


newModel : Model
newModel =
    { form = newForm
    , response = RemoteData.NotAsked
    , validationErrors = Nothing
    }


type alias Form =
    { email : String
    , username : String
    , name : String
    , password : String
    }


newForm : Form
newForm =
    { email = ""
    , username = ""
    , name = ""
    , password = ""
    }


type Field
    = Field_Email
    | Field_Username
    | Field_Name
    | Field_Password


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
            case formValidator model.form of
                Err errors ->
                    ( { model
                        | validationErrors = Just errors
                      }
                    , Cmd.none
                    , Actions.none
                    )

                Ok input ->
                    ( { model
                        | response = RemoteData.Loading
                        , validationErrors = Nothing
                      }
                    , createMutationCmd context input
                    , Actions.none
                    )

        OnResponse result ->
            case result of
                Err e ->
                    ( { model | response = RemoteData.Failure e }
                    , Cmd.none
                    , Actions.addErrorNotification
                        "Something went wrong"
                    )

                Ok response ->
                    if response.success then
                        ( { model
                            | response = RemoteData.Success response
                            , form = newForm
                          }
                        , Nav.pushUrl context.navKey (Routes.pathFor Routes.routeForAdminHome)
                        , Actions.addSuccessNotification "Investor created"
                        )

                    else
                        ( { model | response = RemoteData.Success response }
                        , Cmd.none
                        , Actions.none
                        )


view : Context -> Model -> Html Msg
view context model =
    section [ class molecules.page.container, class "flex justify-center" ]
        [ div [ style "width" "24rem", class "mt-6" ]
            [ Forms.form_ (formArgs model) ]
        ]


formArgs : Model -> Forms.Args CreateUserResponse Msg
formArgs model =
    { title = "Create investor"
    , intro = Nothing
    , submitContent = submitContent
    , fields = formFields model
    , onSubmit = Submit
    , response = model.response
    }


submitContent =
    [ i [ class "fas fa-envelope mr-2" ] [], text "Create" ]


formFields model =
    [ Forms.set
        Field_Name
        "Name"
        (input
            [ class molecules.form.input
            , type_ "text"
            , name "name"
            , value model.form.name
            , onInput ChangeName
            ]
            []
        )
        model.validationErrors
    , Forms.set
        Field_Username
        "Username"
        (input
            [ class molecules.form.input
            , type_ "text"
            , name "username"
            , value model.form.username
            , onInput ChangeUsername
            ]
            []
        )
        model.validationErrors
    , Forms.set
        Field_Password
        "Password"
        (input
            [ class molecules.form.input
            , type_ "password"
            , name "password"
            , value model.form.password
            , onInput ChangePassword
            ]
            []
        )
        model.validationErrors
    , Forms.set
        Field_Email
        "Email (optional)"
        (input
            [ class molecules.form.input
            , type_ "email"
            , name "email"
            , value model.form.email
            , onInput ChangeEmail
            ]
            []
        )
        model.validationErrors
    ]


type alias ValidationError =
    ( Field, String )


formValidator : Validator ValidationError Form CreateUserInput
formValidator =
    validate CreateUserInput
        |> verify .email verifyEmail
        |> verify .username verifyUsername
        |> verify .name verifyName
        |> verify .password verifyPassword


verifyEmail : Validator ValidationError String (OptionalArgument.OptionalArgument String)
verifyEmail email =
    if String.isEmpty email then
        Ok OptionalArgument.Absent

    else if Forms.isValidEmail email then
        Ok (OptionalArgument.Present email)

    else
        Err
            ( ( Field_Email, "Invalid email" )
            , []
            )


verifyUsername : Validator ValidationError String String
verifyUsername =
    String.Verify.notBlank ( Field_Username, "Enter a username" )


verifyName : Validator ValidationError String String
verifyName =
    String.Verify.notBlank ( Field_Name, "Enter a name" )


verifyPassword : Validator ValidationError String String
verifyPassword =
    String.Verify.notBlank ( Field_Password, "Enter a password" )



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
    SelectionSet.succeed identity
        |> with
            (Api.Mutation.createUser
                { input = input }
                createUserResponseSelection
            )


createUserResponseSelection : SelectionSet CreateUserResponse Api.Object.CreateUserResponse
createUserResponseSelection =
    SelectionSet.succeed CreateUserResponse
        |> with Api.Object.CreateUserResponse.success
        |> with (Api.Object.CreateUserResponse.errors mutationErrorSelection)
        |> with (Api.Object.CreateUserResponse.user userSelection)


userSelection : SelectionSet User Api.Object.User
userSelection =
    SelectionSet.succeed User
        |> with Api.Object.User.name
