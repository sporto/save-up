-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.Transaction exposing (accountId, amountInCents, balanceInCents, createdAt, id, kind)

import Api.Enum.TransactionKind
import Api.InputObject
import Api.Interface
import Api.Object
import Api.Scalar
import Api.ScalarCodecs
import Api.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


id : SelectionSet Int Api.Object.Transaction
id =
    Object.selectionForField "Int" "id" [] Decode.int


createdAt : SelectionSet Api.ScalarCodecs.NaiveDateTime Api.Object.Transaction
createdAt =
    Object.selectionForField "ScalarCodecs.NaiveDateTime" "createdAt" [] (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapCodecs |> .codecNaiveDateTime |> .decoder)


accountId : SelectionSet Int Api.Object.Transaction
accountId =
    Object.selectionForField "Int" "accountId" [] Decode.int


kind : SelectionSet Api.Enum.TransactionKind.TransactionKind Api.Object.Transaction
kind =
    Object.selectionForField "Enum.TransactionKind.TransactionKind" "kind" [] Api.Enum.TransactionKind.decoder


amountInCents : SelectionSet Float Api.Object.Transaction
amountInCents =
    Object.selectionForField "Float" "amountInCents" [] Decode.float


balanceInCents : SelectionSet Float Api.Object.Transaction
balanceInCents =
    Object.selectionForField "Float" "balanceInCents" [] Decode.float
