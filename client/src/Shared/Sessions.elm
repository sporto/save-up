port module Shared.Sessions exposing (SignIn, SignUp, asEmailInSignUp, asNameInSignUp, asPasswordInSignUp, authenticate, decodeToken, endSession, newSignIn, newSignUp, startSession)

import ApiPub.InputObject
import Browser.Navigation as Nav
import Json.Decode as Decode exposing (Decoder, field)
import Json.Decode.Pipeline as P
import Jwt exposing (JwtError)
import Shared.Actions as Actions exposing (Actions)
import Shared.Globals exposing (..)
import Shared.Routes as Routes
import Time exposing (Posix)


type alias SignUp =
    ApiPub.InputObject.SignUp


newSignUp : SignUp
newSignUp =
    { email = ""
    , name = ""
    , password = ""
    }


asEmailInSignUp : SignUp -> String -> SignUp
asEmailInSignUp signUp email =
    { signUp | email = email }


asNameInSignUp : SignUp -> String -> SignUp
asNameInSignUp signUp name =
    { signUp | name = name }


asPasswordInSignUp : SignUp -> String -> SignUp
asPasswordInSignUp signUp password =
    { signUp | password = password }


type alias SignIn =
    ApiPub.InputObject.SignIn


newSignIn : SignIn
newSignIn =
    { email = ""
    , password = ""
    }


decodeToken : String -> Result JwtError TokenData
decodeToken token =
    Jwt.decodeToken tokenDecoder token


tokenDecoder : Decode.Decoder TokenData
tokenDecoder =
    Decode.succeed TokenData
        |> P.required "exp" decodeExp
        |> P.required "userId" Decode.int
        |> P.required "email" Decode.string
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


startSession : Nav.Key -> String -> Model a -> ( Model a, Cmd msg, Actions msg )
startSession navKey token model =
    case authenticate token of
        Just authentication ->
            let
                route =
                    case authentication.data.role of
                        Admin ->
                            Routes.routeForAdminHome

                        Investor ->
                            Routes.routeForInvestorHome

                path =
                    Routes.pathFor route
            in
            ( { model | authentication = Just authentication }
            , Cmd.batch
                [ toJsStoreToken token
                , Nav.pushUrl navKey path
                ]
            , Actions.none
            )

        Nothing ->
            ( model, Cmd.none, Actions.none )


endSession : Nav.Key -> Model a -> ( Model a, Cmd msg, Actions msg )
endSession navKey model =
    let
        path =
            Routes.pathFor Routes.routeForSignIn
    in
    ( { model | authentication = Nothing }
    , Cmd.batch
        [ toJsRemoveToken ()
        , Nav.pushUrl navKey path
        ]
    , Actions.none
    )


port toJsStoreToken : String -> Cmd msg


port toJsRemoveToken : () -> Cmd msg
