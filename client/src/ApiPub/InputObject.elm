-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module ApiPub.InputObject exposing (ConfirmEmailInput, ConfirmEmailInputRequiredFields, RedeemInvitationInput, RedeemInvitationInputRequiredFields, SignIn, SignInRequiredFields, SignUp, SignUpRequiredFields, buildConfirmEmailInput, buildRedeemInvitationInput, buildSignIn, buildSignUp, encodeConfirmEmailInput, encodeRedeemInvitationInput, encodeSignIn, encodeSignUp)

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


buildConfirmEmailInput : ConfirmEmailInputRequiredFields -> ConfirmEmailInput
buildConfirmEmailInput required =
    { token = required.token }


type alias ConfirmEmailInputRequiredFields =
    { token : String }


{-| Type for the ConfirmEmailInput input object.
-}
type alias ConfirmEmailInput =
    { token : String }


{-| Encode a ConfirmEmailInput into a value that can be used as an argument.
-}
encodeConfirmEmailInput : ConfirmEmailInput -> Value
encodeConfirmEmailInput input =
    Encode.maybeObject
        [ ( "token", Encode.string input.token |> Just ) ]


buildRedeemInvitationInput : RedeemInvitationInputRequiredFields -> RedeemInvitationInput
buildRedeemInvitationInput required =
    { username = required.username, name = required.name, password = required.password, token = required.token }


type alias RedeemInvitationInputRequiredFields =
    { username : String, name : String, password : String, token : String }


{-| Type for the RedeemInvitationInput input object.
-}
type alias RedeemInvitationInput =
    { username : String, name : String, password : String, token : String }


{-| Encode a RedeemInvitationInput into a value that can be used as an argument.
-}
encodeRedeemInvitationInput : RedeemInvitationInput -> Value
encodeRedeemInvitationInput input =
    Encode.maybeObject
        [ ( "username", Encode.string input.username |> Just ), ( "name", Encode.string input.name |> Just ), ( "password", Encode.string input.password |> Just ), ( "token", Encode.string input.token |> Just ) ]


buildSignIn : SignInRequiredFields -> SignIn
buildSignIn required =
    { usernameOrEmail = required.usernameOrEmail, password = required.password }


type alias SignInRequiredFields =
    { usernameOrEmail : String, password : String }


{-| Type for the SignIn input object.
-}
type alias SignIn =
    { usernameOrEmail : String, password : String }


{-| Encode a SignIn into a value that can be used as an argument.
-}
encodeSignIn : SignIn -> Value
encodeSignIn input =
    Encode.maybeObject
        [ ( "usernameOrEmail", Encode.string input.usernameOrEmail |> Just ), ( "password", Encode.string input.password |> Just ) ]


buildSignUp : SignUpRequiredFields -> SignUp
buildSignUp required =
    { name = required.name, username = required.username, email = required.email, password = required.password }


type alias SignUpRequiredFields =
    { name : String, username : String, email : String, password : String }


{-| Type for the SignUp input object.
-}
type alias SignUp =
    { name : String, username : String, email : String, password : String }


{-| Encode a SignUp into a value that can be used as an argument.
-}
encodeSignUp : SignUp -> Value
encodeSignUp input =
    Encode.maybeObject
        [ ( "name", Encode.string input.name |> Just ), ( "username", Encode.string input.username |> Just ), ( "email", Encode.string input.email |> Just ), ( "password", Encode.string input.password |> Just ) ]
