module Shared.Css exposing
    ( molecules
    , notificationArgs
    )

import Notifications


buttonBase =
    "py-2 px-4 rounded no-underline "


molecules =
    { button =
        { primary = buttonBase ++ "font-bold bg-indigo-500 hover:bg-indigo-700 text-white"
        , secondary = buttonBase ++ "border border-grey text-grey-dark hover:text-gray-800"
        }
    , form =
        { label = "blocktext-sm font-bold"
        , fieldset = "mt-6"
        , input = "appearance-none border w-full py-2 px-3 text-gray-800 leading-tight mt-1"
        , actions = "mt-8"
        , submit = "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
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
        |> Notifications.withSuccessClass "text-green-500 border-green-500 bg-green-100"
        |> Notifications.withErrorClass "text-red-500 border-red-500 bg-red-100"
        |> Notifications.withInfoClass "text-blue-500 border-blue-500 bg-blue-100"
