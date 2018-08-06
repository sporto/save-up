module Shared.GraphQl exposing (..)

import Api.Object
import Api.Object.MutationError
import Graphqelm.Http
import Graphqelm.Operation exposing (RootQuery, RootMutation)
import Graphqelm.SelectionSet exposing (SelectionSet, with)
import RemoteData
import Shared.Context exposing (PublicContext)


type alias GraphData a =
    RemoteData.RemoteData (Graphqelm.Http.Error a) a

type alias GraphResponse a =
    Result (Graphqelm.Http.Error a) a


type alias MutationError =
    { key : String
    , messages : List String
    }


mutationErrorSelection : SelectionSet MutationError Api.Object.MutationError
mutationErrorSelection =
    Api.Object.MutationError.selection MutationError
        |> with Api.Object.MutationError.key
        |> with Api.Object.MutationError.messages


apiEndPointPublic : PublicContext -> String -> String
apiEndPointPublic context id =
    context.flags.apiHost ++ "/graphql?id=" ++ id


sendPublicMutation :
    PublicContext
    -> String
    -> SelectionSet response RootMutation
    -> (GraphResponse response -> msg)
    -> Cmd msg
sendPublicMutation context mutationId mutation onResponse =
    mutation
        |> Graphqelm.Http.mutationRequest (apiEndPointPublic context mutationId)
        |> Graphqelm.Http.send onResponse