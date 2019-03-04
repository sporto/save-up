-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Enum.State exposing (State(..), decoder, list, toString)

import Json.Decode as Decode exposing (Decoder)


type State
    = Active
    | Archived


list : List State
list =
    [ Active, Archived ]


decoder : Decoder State
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "ACTIVE" ->
                        Decode.succeed Active

                    "ARCHIVED" ->
                        Decode.succeed Archived

                    _ ->
                        Decode.fail ("Invalid State type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representating the Enum to a string that the GraphQL server will recognize.
-}
toString : State -> String
toString enum =
    case enum of
        Active ->
            "ACTIVE"

        Archived ->
            "ARCHIVED"
