module Shared.Css exposing (molecules, notificationArgs)

import Notifications


buttonBase =
    "font-bold py-2 px-4 rounded no-underline "


molecules =
    { button =
        { primary = buttonBase ++ "bg-indigo hover:bg-indigo-dark text-white"
        , secondary = buttonBase ++ "border border-grey text-grey"
        }
    , form =
        { label = "blocktext-sm font-bold"
        , fieldset = "mt-6"
        , input = "appearance-none border w-full py-2 px-3 text-grey-darker leading-tight mt-1"
        , actions = "mt-8"
        , submit = "bg-blue hover:bg-blue-dark text-white font-bold py-2 px-4 rounded"
        }
    , page =
        { container = "p-4"
        , title = "mt-6"
        }
    }


notificationArgs : Notifications.Args
notificationArgs =
    Notifications.args
        |> Notifications.withContainerClass "p-4 border w-64 text-center"
        |> Notifications.withSuccessClass "text-green border-green bg-green-lightest"
        |> Notifications.withErrorClass "text-red border-red bg-red-lightest"
        |> Notifications.withInfoClass "text-blue border-blue bg-blue-lightest"
