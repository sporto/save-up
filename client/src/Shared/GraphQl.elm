module Shared.GraphQl exposing (GraphData, GraphResponse, MutationError, apiEndPoint, apiEndPointPublic, mutationErrorPublicSelection, mutationErrorSelection, sendMutation, sendPublicMutation, sendQuery, unwrapNaiveDateTime)

import Api.Object
import Api.Object.MutationError
import Api.Scalar
import ApiPub.Object
import ApiPub.Object.MutationError
import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import RemoteData
import Shared.Globals exposing (..)
import Time exposing (Posix)


type alias GraphData a =
    RemoteData.RemoteData (Graphql.Http.Error a) a


type alias GraphResponse a =
    Result (Graphql.Http.Error a) a


type alias MutationError =
    { key : String
    , messages : List String
    }


mutationErrorPublicSelection : SelectionSet MutationError ApiPub.Object.MutationError
mutationErrorPublicSelection =
    ApiPub.Object.MutationError.selection MutationError
        |> with ApiPub.Object.MutationError.key
        |> with ApiPub.Object.MutationError.messages


mutationErrorSelection : SelectionSet MutationError Api.Object.MutationError
mutationErrorSelection =
    Api.Object.MutationError.selection MutationError
        |> with Api.Object.MutationError.key
        |> with Api.Object.MutationError.messages


apiEndPointPublic : PublicContext -> String -> String
apiEndPointPublic context id =
    context.flags.apiHost ++ "/graphql-pub?id=" ++ id


apiEndPoint : Context -> String -> String
apiEndPoint context id =
    context.flags.apiHost ++ "/graphql-app?id=" ++ id


sendPublicMutation :
    PublicContext
    -> String
    -> SelectionSet response RootMutation
    -> (GraphResponse response -> msg)
    -> Cmd msg
sendPublicMutation context mutationId mutation onResponse =
    mutation
        |> Graphql.Http.mutationRequest (apiEndPointPublic context mutationId)
        |> Graphql.Http.send onResponse


sendMutation :
    Context
    -> String
    -> SelectionSet response RootMutation
    -> (GraphResponse response -> msg)
    -> Cmd msg
sendMutation context mutationId mutation onResponse =
    mutation
        |> Graphql.Http.mutationRequest (apiEndPoint context mutationId)
        |> Graphql.Http.withHeader "Authorization" ("Bearer " ++ context.auth.token)
        |> Graphql.Http.send onResponse


sendQuery :
    Context
    -> String
    -> SelectionSet response RootQuery
    -> (GraphResponse response -> msg)
    -> Cmd msg
sendQuery context queryId query onResponse =
    query
        |> Graphql.Http.queryRequest (apiEndPoint context queryId)
        |> Graphql.Http.withHeader "Authorization" ("Bearer " ++ context.auth.token)
        |> Graphql.Http.send onResponse


unwrapNaiveDateTime : Api.Scalar.NaiveDateTime -> Result String Posix
unwrapNaiveDateTime (Api.Scalar.NaiveDateTime time) =
    time
        |> String.toInt
        |> Result.fromMaybe "Not an integer"
        |> Result.map Time.millisToPosix
