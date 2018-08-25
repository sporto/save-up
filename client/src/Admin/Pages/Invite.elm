module Admin.Pages.Invite exposing (InvitationResponse, Model, Msg(..), createMutation, createMutationCmd, init, invitationResponseSelection, newModel, submit, subscriptions, update, view)

import Api.Mutation
import Api.Object
import Api.Object.InvitationResponse
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, type_, value)
import Html.Events exposing (onSubmit)
import RemoteData
import Shared.Context exposing (Context)
import Shared.Css exposing (molecules)
import Shared.GraphQl exposing (GraphData, GraphResponse, MutationError, mutationErrorSelection, sendMutation)


type Msg
    = ChangeEmail String
    | Submit
    | OnSubmitResponse (GraphResponse InvitationResponse)


type alias Model =
    { email : String
    , response : GraphData InvitationResponse
    }


newModel : Model
newModel =
    { email = ""
    , response = RemoteData.NotAsked
    }


type alias InvitationResponse =
    { success : Bool
    , errors : List MutationError
    }


init : ( Model, Cmd Msg )
init =
    ( newModel, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Context -> Msg -> Model -> ( Model, Cmd Msg )
update context msg model =
    case msg of
        ChangeEmail email ->
            ( { model | email = email }, Cmd.none )

        Submit ->
            ( { model | response = RemoteData.Loading }
            , createMutationCmd context model.email
            )

        OnSubmitResponse result ->
            case result of
                Err e ->
                    Debug.log
                        (toString e)
                        ( { model | response = RemoteData.Failure e }, Cmd.none )

                Ok response ->
                    if response.success then
                        ( { model | response = RemoteData.Success response }
                        , Cmd.none
                        )

                    else
                        ( { model | response = RemoteData.Success response }
                        , Cmd.none
                        )


view : Model -> Html Msg
view model =
    section []
        [ h1 [] [ text "Invite" ]
        , form [ class "mt-2", onSubmit Submit ]
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
            , p [ class "mt-6" ]
                [ submit model
                ]
            ]
        ]


submit : Model -> Html Msg
submit model =
    case model.response of
        RemoteData.Loading ->
            text "..."

        _ ->
            button [ class molecules.form.submit ] [ text "Sign up" ]



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
    Api.Mutation.selection identity
        |> with
            (Api.Mutation.invite
                { attrs = { email = email } }
                invitationResponseSelection
            )


invitationResponseSelection : SelectionSet InvitationResponse Api.Object.InvitationResponse
invitationResponseSelection =
    Api.Object.InvitationResponse.selection InvitationResponse
        |> with Api.Object.InvitationResponse.success
        |> with (Api.Object.InvitationResponse.errors mutationErrorSelection)
