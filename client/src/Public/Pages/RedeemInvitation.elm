module Public.Pages.RedeemInvitation exposing (Model, Msg, init, subscriptions, update, view)

import ApiPub.InputObject exposing (SignUp)
import ApiPub.Mutation
import ApiPub.Object
import ApiPub.Object.RedeemInvitationResponse
import Browser
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import RemoteData
import Shared.Actions as Actions
import Shared.Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl exposing (GraphData, GraphResponse, MutationError, mutationErrorPublicSelection, sendPublicMutation)
import Shared.Routes as Routes
import Shared.Sessions as Sessions
import UI.Flash as Flash
import UI.Forms as Forms
import UI.Icons as Icons
import UI.PublicLinks as PublicLinks
import Verify exposing (Validator, keep, validate, verify)


type alias Model =
    { form : SignUp
    , invitationToken : String
    , response : GraphData RedeemInvitationResponse
    , validationErrors : Maybe ( ValidationError, List ValidationError )
    }


newModel : Flags -> String -> Model
newModel flags invitationToken =
    { form = Sessions.newSignUp
    , invitationToken = invitationToken
    , response = RemoteData.NotAsked
    , validationErrors = Nothing
    }


type alias ValidationError =
    ( Field, String )


type Field
    = Field_Name
    | Field_Username
    | Field_Password


type alias RedeemInvitationResponse =
    { success : Bool
    , errors : List MutationError
    , jwt : Maybe String
    }


asFormInModel : Model -> SignUp -> Model
asFormInModel model form =
    { model | form = form }


type alias Returns =
    ( Model, Cmd Msg, Actions.Actions Msg )


init : PublicContext -> String -> Returns
init context invitationToken =
    ( newModel context.flags invitationToken
    , Cmd.none
    , Actions.none
    )


type Msg
    = ChangeName String
    | ChangePassword String
    | Submit
    | OnSubmitResponse (GraphResponse RedeemInvitationResponse)


update : PublicContext -> Msg -> Model -> Returns
update context msg model =
    case msg of
        ChangeName name ->
            ( name
                |> Sessions.asNameInSignUp model.form
                |> asFormInModel model
            , Cmd.none
            , Actions.none
            )

        ChangePassword password ->
            ( password
                |> Sessions.asPasswordInSignUp model.form
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
                    , sendRedeemMutation context
                        model.form
                        model.invitationToken
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
                    case response.jwt of
                        Just jwt ->
                            ( { model | response = RemoteData.Success response }
                            , Cmd.none
                            , Actions.startSession jwt
                            )

                        Nothing ->
                            ( { model | response = RemoteData.Success response }
                            , Cmd.none
                            , Actions.none
                            )


validateForm : Validator ValidationError SignUp SignUp
validateForm =
    validate SignUp
        |> verify .name (Forms.verifyName Field_Name)
        |> verify .username (Forms.verifyUsername Field_Username)
        |> keep .email
        |> verify .password (Forms.verifyPassword Field_Password)


subscriptions model =
    Sub.none


view : PublicContext -> Model -> Html Msg
view context model =
    div [ class "flex items-center justify-center pt-16" ]
        [ div [ class "w-1/3" ]
            [ div
                [ class "bg-white shadow-md rounded p-8 mt-3" ]
                [ Forms.form_ (formArgs model)
                ]
            , PublicLinks.view context
            ]
        ]


formArgs : Model -> Forms.Args RedeemInvitationResponse Msg
formArgs model =
    { title = "Sign up"
    , intro = Nothing
    , submitContent = [ text "Sign up" ]
    , fields = formFields model
    , onSubmit = Submit
    , response = model.response
    }


formFields model =
    [ Forms.set
        Field_Name
        "Name"
        (input
            [ class molecules.form.input
            , onInput ChangeName
            , value model.form.name
            ]
            []
        )
        model.validationErrors
    , Forms.set
        Field_Password
        "Password"
        (input
            [ class molecules.form.input
            , onInput ChangePassword
            , type_ "password"
            , value model.form.password
            ]
            []
        )
        model.validationErrors
    ]



-- GraphQL data


sendRedeemMutation : PublicContext -> SignUp -> String -> Cmd Msg
sendRedeemMutation context signUp invitationToken =
    sendPublicMutation
        context
        "reedeem-invitation"
        (createRedeemMutation signUp invitationToken)
        OnSubmitResponse


createRedeemMutation : SignUp -> String -> SelectionSet RedeemInvitationResponse RootMutation
createRedeemMutation signUp invitationToken =
    let
        input : ApiPub.InputObject.RedeemInvitationInput
        input =
            { name = signUp.name
            , username = signUp.username
            , password = signUp.password
            , token = invitationToken
            }
    in
    ApiPub.Mutation.selection identity
        |> with
            (ApiPub.Mutation.redeemInvitation
                { input = input }
                redeemResponseSelection
            )


redeemResponseSelection : SelectionSet RedeemInvitationResponse ApiPub.Object.RedeemInvitationResponse
redeemResponseSelection =
    ApiPub.Object.RedeemInvitationResponse.selection RedeemInvitationResponse
        |> with ApiPub.Object.RedeemInvitationResponse.success
        |> with (ApiPub.Object.RedeemInvitationResponse.errors mutationErrorPublicSelection)
        |> with ApiPub.Object.RedeemInvitationResponse.jwt
