module Shared.GraphQl exposing (GraphData, GraphResponse, MutationError, apiEndPoint, apiEndPointPublic, mutationErrorPublicSelection, mutationErrorSelection, sendMutation, sendPublicMutation)

import Api.Object
import Api.Object.MutationError
import ApiPub.Object
import ApiPub.Object.MutationError
import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import RemoteData
import Shared.Context exposing (Context, PublicContext)


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
        |> Graphql.Http.withHeader "Authorization" ("Bearer " ++ context.flags.token)
        |> Graphql.Http.send onResponse
