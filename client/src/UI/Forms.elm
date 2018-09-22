module UI.Forms exposing (mutationError, set)

import Html exposing (..)
import Html.Attributes exposing (class)
import Shared.Css exposing (molecules)
import Shared.GraphQl exposing (MutationError)
import UI.Flash as Flash


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
    fieldset []
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
            text ""

        Nothing ->
            text ""
