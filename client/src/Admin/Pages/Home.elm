module Admin.Pages.Home exposing (Model, Msg, init, subscriptions, update, view)

import Api.Object
import Api.Object.Account
import Api.Object.AdminViewer
import Api.Object.User
import Api.Query
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class)
import RemoteData
import Shared.Context exposing (Context)
import Shared.GraphQl as GraphQl exposing (GraphData, GraphResponse)


type Msg
    = NoOp
    | OnData (GraphResponse Data)


type alias Model =
    { data : GraphData Data
    }


newModel =
    { data = RemoteData.NotAsked
    }


init : Context -> ( Model, Cmd Msg )
init context =
    ( newModel, getData context )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Context -> Msg -> Model -> ( Model, Cmd Msg )
update context msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        OnData result ->
            case result of
                Err e ->
                    ({model |
                    response = RemoteData.Failure e}
                    , Cmd.none
                    )

                Ok data ->
                    ( {model
                    | data = RemoteData.Success data
                    }, Cmd.none )


view : Context -> Model -> Html msg
view context model =
    section []
        [ h1 [] [ text "Welcome" ]
        , p [ class "mt-3" ] [ text "You don't have any investors, please invite one by clicking the invite link above." ]
        ]



-- DATA
-- We want balance
-- Investor name


type alias Data =
    { investors : List Investor
    }


type alias Investor =
    { accounts : List Account
    , name : String
    }


type alias Account =
    { name : String
    }


getData : Context -> Cmd Msg
getData context =
    GraphQl.sendQuery
        context
        "data-home"
        dataQuery
        OnData


dataQuery : SelectionSet Data RootQuery
dataQuery =
    Api.Query.selection identity
        |> with (Api.Query.admin adminNode)


adminNode : SelectionSet Data Api.Object.AdminViewer
adminNode =
    Api.Object.AdminViewer.selection Data
        |> with (Api.Object.AdminViewer.investors investorNode)


investorNode : SelectionSet Investor Api.Object.User
investorNode =
    Api.Object.User.selection Investor
        |> with (Api.Object.User.accounts accountNode)
        |> with Api.Object.User.name


accountNode : SelectionSet Account Api.Object.Account
accountNode =
    Api.Object.Account.selection Account
        |> with Api.Object.Account.name
