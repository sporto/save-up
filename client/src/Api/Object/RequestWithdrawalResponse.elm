-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.RequestWithdrawalResponse exposing (errors, selection, success, transactionRequest)

import Api.InputObject
import Api.Interface
import Api.Object
import Api.Scalar
import Api.Union
import Graphql.Field as Field exposing (Field)
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


{-| Select fields to build up a SelectionSet for this object.
-}
selection : (a -> constructor) -> SelectionSet (a -> constructor) Api.Object.RequestWithdrawalResponse
selection constructor =
    Object.selection constructor


success : Field Bool Api.Object.RequestWithdrawalResponse
success =
    Object.fieldDecoder "success" [] Decode.bool


errors : SelectionSet decodesTo Api.Object.MutationError -> Field (List decodesTo) Api.Object.RequestWithdrawalResponse
errors object_ =
    Object.selectionField "errors" [] object_ (identity >> Decode.list)


transactionRequest : SelectionSet decodesTo Api.Object.TransactionRequest -> Field (Maybe decodesTo) Api.Object.RequestWithdrawalResponse
transactionRequest object_ =
    Object.selectionField "transactionRequest" [] object_ (identity >> Decode.nullable)