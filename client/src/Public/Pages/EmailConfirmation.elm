module Public.Pages.EmailConfirmation exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import ApiPub.InputObject
import ApiPub.Mutation
import ApiPub.Object
import ApiPub.Object.ConfirmEmailResponse
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Notifications
import Public.Pages.Common as Common
import RemoteData
import Shared.Actions as Actions exposing (Actions)
import Shared.Css as Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl exposing (GraphData, GraphResponse, MutationError, mutationErrorPublicSelection, sendPublicMutation)
import String.Verify
import UI.Empty as Empty
import UI.Flash as Flash
import UI.Forms as Forms
import UI.Icons as Icons
import UI.PublicLinks as PublicLinks
import Verify exposing (Validator, validate, verify)


type alias Model =
    { token : String
    , response : GraphData Response
    }


newModel : String -> Model
newModel token =
    { token = token
    , response = RemoteData.NotAsked
    }


type alias Returns =
    ( Model, Cmd Msg, Actions Msg )


type alias Response =
    { success : Bool
    , errors : List MutationError
    }


init : PublicContext -> String -> Returns
init context token =
    ( newModel token
        |> (\model -> { model | response = RemoteData.Loading })
    , sendMutation context
        token
    , Actions.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type Msg
    = OnSubmitResponse (GraphResponse Response)


update : PublicContext -> Msg -> Model -> Returns
update context msg model =
    case msg of
        OnSubmitResponse result ->
            case result of
                Err e ->
                    ( { model | response = RemoteData.Failure e }
                    , Cmd.none
                    , Actions.addErrorNotification
                        "Something went wrong"
                    )

                Ok response ->
                    ( { model | response = RemoteData.Success response }
                    , Cmd.none
                    , Actions.none
                    )


view : PublicContext -> Model -> Html Msg
view context model =
    let
        children =
            case model.response of
                RemoteData.NotAsked ->
                    [ Empty.loading ]

                RemoteData.Loading ->
                    [ Empty.loading ]

                RemoteData.Failure err ->
                    [ Empty.graphError e ]

                RemoteData.Success data ->
                    viewWithData data
    in
    Common.layout
        context
        { containerAttributes = [ class "w-80" ]
        }
        children


viewWithData : Response -> List (Html Msg)
viewWithData response =
    if response.success then
        [ text "Success" ]

    else
        response.errors
            |> List.map Forms.mutationErrorV2


sendMutation : PublicContext -> String -> Cmd Msg
sendMutation context token =
    sendPublicMutation
        context
        "email-confirmation"
        (mutation token)
        OnSubmitResponse


mutation : String -> SelectionSet Response RootMutation
mutation token =
    let
        input : ApiPub.InputObject.ConfirmEmailInput
        input =
            { token = token
            }
    in
    SelectionSet.succeed identity
        |> with
            (ApiPub.Mutation.confirmEmail
                { input = input }
                responseSelection
            )


responseSelection : SelectionSet Response ApiPub.Object.ConfirmEmailResponse
responseSelection =
    SelectionSet.succeed Response
        |> with ApiPub.Object.ConfirmEmailResponse.success
        |> with (ApiPub.Object.ConfirmEmailResponse.errors mutationErrorPublicSelection)
