-- Do not manually edit this file, it was auto-generated by Graphqelm
-- https://github.com/dillonkearns/graphqelm


module Api.InputObject exposing (..)

import Api.Interface
import Api.Object
import Api.Scalar
import Api.Union
import Graphqelm.Field as Field exposing (Field)
import Graphqelm.Internal.Builder.Argument as Argument exposing (Argument)
import Graphqelm.Internal.Builder.Object as Object
import Graphqelm.Internal.Encode as Encode exposing (Value)
import Graphqelm.OptionalArgument exposing (OptionalArgument(Absent))
import Graphqelm.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


buildInvitationInput : InvitationInputRequiredFields -> InvitationInput
buildInvitationInput required =
    { email = required.email }


type alias InvitationInputRequiredFields =
    { email : String }


{-| Type for the InvitationInput input object.
-}
type alias InvitationInput =
    { email : String }


{-| Encode a InvitationInput into a value that can be used as an argument.
-}
encodeInvitationInput : InvitationInput -> Value
encodeInvitationInput input =
    Encode.maybeObject
        [ ( "email", Encode.string input.email |> Just ) ]
