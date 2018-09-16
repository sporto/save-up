module Investor.Pages.Home exposing (Model, Msg, init, subscriptions, update, view)

-- import Api.Object
-- import Api.Object.Account
-- import Api.Object.AdminViewer
-- import Api.Object.User
-- import Api.Query
-- import Graphql.Field as Field
-- import Graphql.Operation exposing (RootQuery)
-- import Graphql.SelectionSet exposing (SelectionSet, with)

import Html exposing (..)
import Html.Attributes exposing (class, href, name, src, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Shared.Actions as Actions
import Shared.Css exposing (molecules)
import Shared.Globals exposing (..)


type alias Model =
    ()


initialModel : Flags -> Model
initialModel flags =
    ()


type Msg
    = NoOp


type alias Returns =
    ( Model, Cmd Msg, Actions.Actions Msg )


init : Context -> Returns
init context =
    ( initialModel context.flags, Cmd.none, Actions.none )


update : Context -> Msg -> Model -> Returns
update context msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none, Actions.none )


subscriptions model =
    Sub.none


view : Context -> Model -> Html Msg
view context model =
    section [ class molecules.page.container ]
        [ h1 [ class molecules.page.title ] [ text "Your account" ]
        , div [ class "mt-8 flex justify-center" ]
            [ img [ src "https://via.placeholder.com/600x320" ] []
            ]
        ]



-- DATA
-- type alias Account =
--     { id : Int
--     , balanceInCents : Int
--     }
-- getData : Context -> Cmd Msg
-- getData context =
--     GraphQl.sendQuery
--         context
--         "data-home"
--         dataQuery
--         OnData
-- dataQuery : SelectionSet Data RootQuery
-- dataQuery =
--     Api.Query.selection identity
--         |> with (Api.Query.admin adminNode)
-- adminNode : SelectionSet Data Api.Object.AdminViewer
-- adminNode =
--     Api.Object.AdminViewer.selection Data
--         |> with (Api.Object.AdminViewer.investors investorNode)
-- investorNode : SelectionSet Investor Api.Object.User
-- investorNode =
--     Api.Object.User.selection Investor
--         |> with (Api.Object.User.accounts accountNode)
--         |> with Api.Object.User.name
-- accountNode : SelectionSet Account Api.Object.Account
-- accountNode =
--     Api.Object.Account.selection Account
--         |> with Api.Object.Account.id
--         |> with (Api.Object.Account.balanceInCents |> Field.map round)
--         |> with Api.Object.Account.name
