module UI.Forms exposing (..)

import Html exposing (..)
import UI.Flash as Flash
import Shared.GraphQl exposing (MutationError)


mutationError : String -> List MutationError -> Html msg
mutationError key errors =
    errors
        |> List.filter (\error -> error.key == key)
        |> List.map (.messages >> String.join ", ")
        |> List.map Flash.error
        |> div []
