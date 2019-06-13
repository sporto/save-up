module Main exposing (main)

import Html
import Html.Attributes exposing (style)
import UIExplorer exposing (UIExplorerProgram, defaultConfig, explore, storiesOf)

button : String -> String -> Html.Html msg
button label bgColor =
    Html.button
        [ style "background-color" bgColor ]
        [ Html.text label ]

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
        ]

