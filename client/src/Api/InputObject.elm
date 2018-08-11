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


buildSignIn : SignInRequiredFields -> SignIn
buildSignIn required =
    { email = required.email, password = required.password }


type alias SignInRequiredFields =
    { email : String, password : String }


{-| Type for the SignIn input object.
-}
type alias SignIn =
    { email : String, password : String }


{-| Encode a SignIn into a value that can be used as an argument.
-}
encodeSignIn : SignIn -> Value
encodeSignIn input =
    Encode.maybeObject
        [ ( "email", Encode.string input.email |> Just ), ( "password", Encode.string input.password |> Just ) ]


buildSignUp : SignUpRequiredFields -> SignUp
buildSignUp required =
    { name = required.name, email = required.email, password = required.password }


type alias SignUpRequiredFields =
    { name : String, email : String, password : String }


{-| Type for the SignUp input object.
-}
type alias SignUp =
    { name : String, email : String, password : String }


{-| Encode a SignUp into a value that can be used as an argument.
-}
encodeSignUp : SignUp -> Value
encodeSignUp input =
    Encode.maybeObject
        [ ( "name", Encode.string input.name |> Just ), ( "email", Encode.string input.email |> Just ), ( "password", Encode.string input.password |> Just ) ]
