module UI.Forms exposing (mutationError)

import Html exposing (..)
import Shared.GraphQl exposing (MutationError)
import UI.Flash as Flash


mutationError : String -> List MutationError -> Html msg
mutationError key errors =
    errors
        |> List.filter (\error -> error.key == key)
        |> List.map (.messages >> String.join ", ")
        |> List.map Flash.error
        |> div []
