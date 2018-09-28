module Public.Pages.ResetPassword exposing (Model, Msg, init, subscriptions, update, view)

import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Notifications
import RemoteData
import Shared.Actions as Actions
import Shared.Css as Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl exposing (GraphData, GraphResponse, MutationError, mutationErrorPublicSelection, sendPublicMutation)
import String.Verify
import UI.Flash as Flash
import UI.Forms as Forms
import UI.Icons as Icons
import UI.PublicLinks as PublicLinks
import Verify exposing (Validator, validate, verify)


type alias Model =
    {}


type Msg
    = NoOp


init context token =
    ( {}, Cmd.none, Actions.none )


subscriptions model =
    Sub.none


update context msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none, Actions.none )


view context model =
    div [] []
