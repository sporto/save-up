-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.Admin exposing (AccountRequiredArguments, account, investors, pendingRequests, selection)

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
selection : (a -> constructor) -> SelectionSet (a -> constructor) Api.Object.Admin
selection constructor =
    Object.selection constructor


investors : SelectionSet decodesTo Api.Object.User -> Field (List decodesTo) Api.Object.Admin
investors object_ =
    Object.selectionField "investors" [] object_ (identity >> Decode.list)


type alias AccountRequiredArguments =
    { id : Int }


account : AccountRequiredArguments -> SelectionSet decodesTo Api.Object.Account -> Field decodesTo Api.Object.Admin
account requiredArgs object_ =
    Object.selectionField "account" [ Argument.required "id" requiredArgs.id Encode.int ] object_ identity


pendingRequests : SelectionSet decodesTo Api.Object.TransactionRequest -> Field (List decodesTo) Api.Object.Admin
pendingRequests object_ =
    Object.selectionField "pendingRequests" [] object_ (identity >> Decode.list)
