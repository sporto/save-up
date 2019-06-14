module Main exposing (main)

import Html
import Html.Attributes exposing (style)
import UI.Forms as Forms
import UIExplorer exposing (UIExplorerProgram, defaultConfig, explore, storiesOf)


button : String -> String -> Html.Html msg
button label bgColor =
    Html.button
        [ style "background-color" bgColor ]
        [ Html.text label ]


type Field
    = Field


main : UIExplorerProgram {} () {}
main =
    explore
        defaultConfig
        [ storiesOf
            "Button"
            [ ( "SignIn", \_ -> button "Sign In" "pink", {} )
            , ( "SignOut", \_ -> button "Sign Out" "cyan", {} )
            , ( "Loading", \_ -> button "Loading please wait..." "white", {} )
            ]
        , storiesOf
            "MutationErrors"
            [ ( "WithError"
              , \_ ->
                    Forms.mutationErrorV2
                        { key = "username"
                        , messages = [ "Is not unique" ]
                        }
              , {}
              )
            ]
        , storiesOf
            "Form.setError"
            [ ( "WithError"
              , \_ ->
                    Forms.setError Field [ ( Field, "Is invalid" ) ]
              , {}
              )
            ]
        ]
