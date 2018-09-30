module Admin.Pages.Requests exposing (Model, Msg, init, subscriptions, update, view)

import Api.Enum.TransactionKind exposing (TransactionKind)
import Api.InputObject
import Api.Mutation
import Api.Object
import Api.Object.Account
import Api.Object.Admin
import Api.Object.TransactionRequest
import Api.Object.User
import Api.Query
import Browser.Navigation as Nav
import Graphql.Field as Field
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.OptionalArgument as OptionalArgument
import Graphql.SelectionSet exposing (SelectionSet, with)
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
import UI.Chart as Chart
import UI.Empty as Empty
import UI.Flash as Flash
import UI.Forms as Forms
import UI.Icons as Icons
import Verify exposing (Validator, validate, verify)


type Msg
    = OnData (GraphResponse Data)


type alias Model =
    { data : GraphData Data
    }


newModel : Model
newModel =
    { data = RemoteData.NotAsked
    }


type alias Data =
    { pendingRequests : List PendingRequest
    }


type alias PendingRequest =
    { amountInCents : Float
    , kind : TransactionKind
    , user : String
    }


type alias Returns =
    ( Model, Cmd Msg, Actions.Actions Msg )


init : Context -> Returns
init context =
    ( newModel, dataCmd context, Actions.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Context -> Msg -> Model -> Returns
update context msg model =
    case msg of
        OnData result ->
            case result of
                Err e ->
                    ( { model | data = RemoteData.Failure e }
                    , Cmd.none
                    , Actions.addErrorNotification
                        "Something went wrong"
                    )

                Ok data ->
                    ( { model | data = RemoteData.Success data }
                    , Cmd.none
                    , Actions.none
                    )


view : Context -> Model -> Html Msg
view context model =
    section [ class molecules.page.container, class "flex justify-center" ]
        [ div [ style "width" "24rem", class "mt-6" ]
            []
        ]



-- GraphQl


dataCmd : Context -> Cmd Msg
dataCmd context =
    GraphQl.sendQuery
        context
        "data-requests"
        dataQuery
        OnData


dataQuery : SelectionSet Data RootQuery
dataQuery =
    Api.Query.selection identity
        |> with (Api.Query.admin adminNode)


adminNode : SelectionSet Data Api.Object.Admin
adminNode =
    Api.Object.Admin.selection Data
        |> with (Api.Object.Admin.pendingRequests requestSelection)


requestSelection : SelectionSet PendingRequest Api.Object.TransactionRequest
requestSelection =
    Api.Object.TransactionRequest.selection PendingRequest
        |> with Api.Object.TransactionRequest.amountInCents
        |> with Api.Object.TransactionRequest.kind
        |> with (Api.Object.TransactionRequest.account accountSelection)


accountSelection : SelectionSet String Api.Object.Account
accountSelection =
    Api.Object.Account.selection identity
        |> with (Api.Object.Account.user userSelection)


userSelection : SelectionSet String Api.Object.User
userSelection =
    Api.Object.User.selection identity
        |> with Api.Object.User.name
