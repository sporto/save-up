port module Shared.Sessions exposing
    ( asEmailInSignUp
    , asNameInSignUp
    , asPasswordInSignUp
    , asUsernameInSignUp
    , authenticate
    , decodeToken
    , endSession
    , newSignUp
    , startSession
    )

import ApiPub.InputObject exposing (SignUp)
import Browser.Navigation as Nav
import Json.Decode as Decode exposing (Decoder, field)
import Json.Decode.Pipeline as P
import Jwt exposing (JwtError)
import Process
import Shared.Actions as Actions exposing (Actions)
import Shared.Globals exposing (..)
import Shared.Routes as Routes
import Task
import Time exposing (Posix)


newSignUp : SignUp
newSignUp =
    { email = ""
    , name = ""
    , username = ""
    , password = ""
    }


asEmailInSignUp : SignUp -> String -> SignUp
asEmailInSignUp signUp email =
    { signUp | email = email }


asNameInSignUp : SignUp -> String -> SignUp
asNameInSignUp signUp name =
    { signUp | name = name }


asUsernameInSignUp : SignUp -> String -> SignUp
asUsernameInSignUp signUp username =
    { signUp | username = username }


asUserameInSignUp : SignUp -> String -> SignUp
asUserameInSignUp signUp username =
    { signUp | username = username }


asPasswordInSignUp : SignUp -> String -> SignUp
asPasswordInSignUp signUp password =
    { signUp | password = password }


decodeToken : String -> Result JwtError TokenData
decodeToken token =
    Jwt.decodeToken tokenDecoder token


tokenDecoder : Decode.Decoder TokenData
tokenDecoder =
    Decode.succeed TokenData
        |> P.required "exp" decodeExp
        |> P.required "userId" Decode.int
        |> P.required "username" Decode.string
        |> P.required "email" (Decode.nullable Decode.string)
        |> P.required "name" Decode.string
        |> P.required "role" decodeRole


decodeExp : Decode.Decoder Posix
decodeExp =
    Decode.int
        |> Decode.andThen
            (\ts ->
                Decode.succeed
                    (Time.millisToPosix (ts * 1000))
            )


decodeRole : Decode.Decoder Role
decodeRole =
    Decode.string
        |> Decode.andThen
            (\role ->
                case role of
                    "ADMIN" ->
                        Decode.succeed Admin

                    "INVESTOR" ->
                        Decode.succeed Investor

                    _ ->
                        Decode.fail ("Invalid role " ++ role)
            )


authenticate : String -> Maybe Authentication
authenticate token =
    case decodeToken token of
        Ok data ->
            Just
                { token = token
                , data = data
                }

        Err e ->
            Nothing


type alias Model a =
    { a | authentication : Maybe Authentication }


startSession : String -> Model a -> (Routes.Route -> msg) -> ( Model a, Cmd msg, Actions msg )
startSession token model navigate =
    case authenticate token of
        Just authentication ->
            let
                route =
                    case authentication.data.role of
                        Admin ->
                            Routes.routeForAdminHome

                        Investor ->
                            Routes.routeForInvestorHome

                navigateLater =
                    Process.sleep 100
                        |> Task.perform (\_ -> navigate route)
            in
            ( { model | authentication = Just authentication }
            , Cmd.batch
                [ toJsStoreToken token
                , navigateLater
                ]
            , Actions.none
            )

        Nothing ->
            ( model
            , Cmd.none
            , Actions.addErrorNotification
                "Unable to start session"
            )


endSession : Model a -> (Routes.Route -> msg) -> ( Model a, Cmd msg, Actions msg )
endSession model navigate =
    let
        path =
            Routes.pathFor Routes.routeForSignIn

        navigateLater =
            Process.sleep 100
                |> Task.perform (\_ -> navigate Routes.routeForSignIn)
    in
    ( { model | authentication = Nothing }
    , Cmd.batch
        [ toJsRemoveToken ()
        , navigateLater
        ]
    , Actions.none
    )


port toJsStoreToken : String -> Cmd msg


port toJsRemoveToken : () -> Cmd msg
