-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module ApiPub.Object.RequestPasswordResetResponse exposing (errors, selection, success)

import ApiPub.InputObject
import ApiPub.Interface
import ApiPub.Object
import ApiPub.Scalar
import ApiPub.Union
import Graphql.Field as Field exposing (Field)
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


{-| Select fields to build up a SelectionSet for this object.
-}
selection : (a -> constructor) -> SelectionSet (a -> constructor) ApiPub.Object.RequestPasswordResetResponse
selection constructor =
    Object.selection constructor


success : Field Bool ApiPub.Object.RequestPasswordResetResponse
success =
    Object.fieldDecoder "success" [] Decode.bool


errors : SelectionSet decodesTo ApiPub.Object.MutationError -> Field (List decodesTo) ApiPub.Object.RequestPasswordResetResponse
errors object_ =
    Object.selectionField "errors" [] object_ (identity >> Decode.list)