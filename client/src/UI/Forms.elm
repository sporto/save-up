module UI.Forms exposing (isValidEmail, mustBeEmail, mutationError, set, verifyEmail, verifyName, verifyPassword, verifyUsername)

import Html exposing (..)
import Html.Attributes exposing (class)
import Regex
import Shared.Css exposing (molecules)
import Shared.GraphQl exposing (MutationError)
import String.Verify
import UI.Flash as Flash
import Verify exposing (Validator)


mutationError : String -> List MutationError -> Html msg
mutationError key errors =
    errors
        |> List.filter (\error -> error.key == key)
        |> List.map (.messages >> String.join ", ")
        |> List.map Flash.error
        |> div []


type alias Error field =
    ( field, String )


flattenErrors : Maybe ( Error f, List (Error f) ) -> List (Error f)
flattenErrors maybeErrors =
    case maybeErrors of
        Nothing ->
            []

        Just ( e, es ) ->
            e :: es


set : f -> String -> Html msg -> Maybe ( Error f, List (Error f) ) -> Html msg
set field label_ input_ errors =
    fieldset [ class "mt-6" ]
        [ p []
            [ label [ class molecules.form.label ]
                [ text label_
                ]
            ]
        , p
            []
            [ input_
            ]
        , setError field (flattenErrors errors)
        ]


setError : f -> List (Error f) -> Html msg
setError field errors =
    let
        error =
            errors
                |> List.filter (\( f, m ) -> f == field)
                |> List.head
    in
    case error of
        Just ( _, message ) ->
            p [ class "mt-3 text-red text-sm" ] [ text message ]

        Nothing ->
            text ""


mustBeEmail : error -> Validator error String String
mustBeEmail error input =
    if isValidEmail input then
        Ok input

    else
        Err ( error, [] )


isValidEmail : String -> Bool
isValidEmail email =
    Regex.contains emailRe email


emailRe =
    Regex.fromString "^.+@.+\\..+"
        |> Maybe.withDefault Regex.never


mustBeValidUsername : error -> Validator error String String
mustBeValidUsername error input =
    if isValidUsername input then
        Ok input

    else
        Err ( error, [] )


isValidUsername val =
    Regex.contains usernameRe val


usernameRegex =
    "^[A-Za-z0-9]+(?:[_-][A-Za-z0-9]+)*$"


usernameRe =
    Regex.fromString usernameRegex
        |> Maybe.withDefault Regex.never


verifyEmail : field -> Validator ( field, String ) String String
verifyEmail field =
    String.Verify.notBlank ( field, "Enter an email" )
        |> Verify.compose (mustBeEmail ( field, "Enter a valid email" ))


verifyUsername : field -> Validator ( field, String ) String String
verifyUsername field =
    String.Verify.notBlank ( field, "Enter a username" )
        |> Verify.compose (String.Verify.minLength 6 ( field, "Enter at least 6 characters" ))
        |> Verify.compose (mustBeValidUsername ( field, "Only letters, numbers, -, _ are valid." ))


verifyName : field -> Validator ( field, String ) String String
verifyName field =
    String.Verify.notBlank ( field, "Enter a name" )
        |> Verify.compose (String.Verify.minLength 2 ( field, "Enter at least 2 characters" ))


verifyPassword : field -> Validator ( field, String ) String String
verifyPassword field =
    String.Verify.notBlank ( field, "Enter a password" )
        |> Verify.compose (String.Verify.minLength 8 ( field, "Enter at least 8 characters" ))
