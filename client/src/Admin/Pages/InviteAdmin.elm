module Admin.Pages.InviteAdmin exposing
    ( InvitationResponse
    , Model
    , Msg(..)
    , init
    , newModel
    , subscriptions
    , update
    , view
    )

import Api.Mutation
import Api.Object
import Api.Object.InvitationResponse
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import RemoteData
import Shared.Actions as Actions
import Shared.Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl exposing (GraphData, GraphResponse, MutationError, mutationErrorSelection, sendMutation)
import UI.Flash as Flash
import UI.Forms as Forms
import UI.Icons as Icons
import Verify exposing (Validator, validate, verify)


type Msg
    = ChangeEmail String
    | Submit
    | OnSubmitResponse (GraphResponse InvitationResponse)


type alias Model =
    { form : Form
    , response : GraphData InvitationResponse
    , validationErrors : Maybe ( ValidationError, List ValidationError )
    }


newModel : Model
newModel =
    { form = newForm
    , response = RemoteData.NotAsked
    , validationErrors = Nothing
    }


type alias Form =
    { email : String }


newForm =
    { email = "" }


asEmailInForm form email =
    { form | email = email }


asFormInModel model form =
    { model | form = form }


type alias ValidationError =
    ( Field, String )


type alias InvitationResponse =
    { success : Bool
    , errors : List MutationError
    }


type Field
    = Field_Email


type alias Returns =
    ( Model, Cmd Msg, Actions.Actions Msg )


init : Returns
init =
    ( newModel, Cmd.none, Actions.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Context -> Msg -> Model -> Returns
update context msg model =
    case msg of
        ChangeEmail email ->
            ( email
                |> asEmailInForm model.form
                |> asFormInModel model
            , Cmd.none
            , Actions.none
            )

        Submit ->
            case validateForm model.form of
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
                    , createMutationCmd context model.form.email
                    , Actions.none
                    )

        OnSubmitResponse result ->
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
                            , form =
                                { email = ""
                                }
                          }
                        , Cmd.none
                        , Actions.addSuccessNotification
                            "Admin invited"
                        )

                    else
                        ( { model | response = RemoteData.Success response }
                        , Cmd.none
                        , Actions.none
                        )


validateForm : Validator ValidationError Form Form
validateForm =
    validate Form
        |> verify .email (Forms.verifyEmail Field_Email)


view : Context -> Model -> Html Msg
view context model =
    section [ class molecules.page.container, class "flex justify-center" ]
        [ div [ style "width" "24rem", class "mt-6" ]
            [ Forms.form_ (formArgs model) ]
        ]


formArgs : Model -> Forms.Args InvitationResponse Msg
formArgs model =
    { title = "Invite admin"
    , intro = Just intro
    , submitContent = submitContent
    , fields = formFields model
    , onSubmit = Submit
    , response = model.response
    }


intro =
    [ p [ class "text-grey-dark leading-normal" ]
        [ text "You can invite another parent to manage these accounts with you."
        ]
    ]


submitContent =
    [ i [ class "fas fa-envelope mr-2" ] [], text "Invite" ]


formFields : Model -> List (Html Msg)
formFields model =
    [ Forms.set
        Field_Email
        "Email"
        (input
            [ class molecules.form.input
            , onInput ChangeEmail
            , type_ "email"
            , name "email"
            , value model.form.email
            ]
            []
        )
        model.validationErrors
    ]



-- GraphQl


createMutationCmd : Context -> String -> Cmd Msg
createMutationCmd context email =
    sendMutation
        context
        "create-invitation"
        (createMutation email)
        OnSubmitResponse


createMutation : String -> SelectionSet InvitationResponse RootMutation
createMutation email =
    SelectionSet.succeed identity
        |> with
            (Api.Mutation.inviteAdmin
                { input = { email = email } }
                invitationResponseSelection
            )


invitationResponseSelection : SelectionSet InvitationResponse Api.Object.InvitationResponse
invitationResponseSelection =
    SelectionSet.succeed InvitationResponse
        |> with Api.Object.InvitationResponse.success
        |> with (Api.Object.InvitationResponse.errors mutationErrorSelection)
