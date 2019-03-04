-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Mutation exposing (ArchiveUserRequiredArguments, ChangeAccountInterestRequiredArguments, CreateUserRequiredArguments, DepositRequiredArguments, InviteAdminRequiredArguments, RequestWithdrawRequiredArguments, ResolveTransactionRequestRequiredArguments, UnarchiveUserRequiredArguments, WithdrawRequiredArguments, archiveUser, changeAccountInterest, createUser, deposit, inviteAdmin, requestWithdraw, resolveTransactionRequest, unarchiveUser, withdraw)

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
import Json.Decode as Decode exposing (Decoder)


type alias CreateUserRequiredArguments =
    { input : Api.InputObject.CreateUserInput }


createUser : CreateUserRequiredArguments -> SelectionSet decodesTo Api.Object.CreateUserResponse -> SelectionSet decodesTo RootMutation
createUser requiredArgs object_ =
    Object.selectionForCompositeField "createUser" [ Argument.required "input" requiredArgs.input Api.InputObject.encodeCreateUserInput ] object_ identity


type alias ArchiveUserRequiredArguments =
    { userId : Int }


archiveUser : ArchiveUserRequiredArguments -> SelectionSet decodesTo Api.Object.ArchiveUserResponse -> SelectionSet decodesTo RootMutation
archiveUser requiredArgs object_ =
    Object.selectionForCompositeField "archiveUser" [ Argument.required "userId" requiredArgs.userId Encode.int ] object_ identity


type alias UnarchiveUserRequiredArguments =
    { userId : Int }


unarchiveUser : UnarchiveUserRequiredArguments -> SelectionSet decodesTo Api.Object.UnarchiveUserResponse -> SelectionSet decodesTo RootMutation
unarchiveUser requiredArgs object_ =
    Object.selectionForCompositeField "unarchiveUser" [ Argument.required "userId" requiredArgs.userId Encode.int ] object_ identity


type alias InviteAdminRequiredArguments =
    { input : Api.InputObject.InvitationInput }


inviteAdmin : InviteAdminRequiredArguments -> SelectionSet decodesTo Api.Object.InvitationResponse -> SelectionSet decodesTo RootMutation
inviteAdmin requiredArgs object_ =
    Object.selectionForCompositeField "inviteAdmin" [ Argument.required "input" requiredArgs.input Api.InputObject.encodeInvitationInput ] object_ identity


type alias ChangeAccountInterestRequiredArguments =
    { input : Api.InputObject.ChangeAccountInterestInput }


changeAccountInterest : ChangeAccountInterestRequiredArguments -> SelectionSet decodesTo Api.Object.ChangeAccountInterestResponse -> SelectionSet decodesTo RootMutation
changeAccountInterest requiredArgs object_ =
    Object.selectionForCompositeField "changeAccountInterest" [ Argument.required "input" requiredArgs.input Api.InputObject.encodeChangeAccountInterestInput ] object_ identity


type alias RequestWithdrawRequiredArguments =
    { input : Api.InputObject.RequestWithdrawalInput }


requestWithdraw : RequestWithdrawRequiredArguments -> SelectionSet decodesTo Api.Object.RequestWithdrawalResponse -> SelectionSet decodesTo RootMutation
requestWithdraw requiredArgs object_ =
    Object.selectionForCompositeField "requestWithdraw" [ Argument.required "input" requiredArgs.input Api.InputObject.encodeRequestWithdrawalInput ] object_ identity


type alias ResolveTransactionRequestRequiredArguments =
    { input : Api.InputObject.ResolveTransactionRequestInput }


resolveTransactionRequest : ResolveTransactionRequestRequiredArguments -> SelectionSet decodesTo Api.Object.ResolveTransactionRequestResponse -> SelectionSet decodesTo RootMutation
resolveTransactionRequest requiredArgs object_ =
    Object.selectionForCompositeField "resolveTransactionRequest" [ Argument.required "input" requiredArgs.input Api.InputObject.encodeResolveTransactionRequestInput ] object_ identity


type alias DepositRequiredArguments =
    { input : Api.InputObject.DepositInput }


deposit : DepositRequiredArguments -> SelectionSet decodesTo Api.Object.DepositResponse -> SelectionSet decodesTo RootMutation
deposit requiredArgs object_ =
    Object.selectionForCompositeField "deposit" [ Argument.required "input" requiredArgs.input Api.InputObject.encodeDepositInput ] object_ identity


type alias WithdrawRequiredArguments =
    { input : Api.InputObject.WithdrawalInput }


withdraw : WithdrawRequiredArguments -> SelectionSet decodesTo Api.Object.WithdrawalResponse -> SelectionSet decodesTo RootMutation
withdraw requiredArgs object_ =
    Object.selectionForCompositeField "withdraw" [ Argument.required "input" requiredArgs.input Api.InputObject.encodeWithdrawalInput ] object_ identity
