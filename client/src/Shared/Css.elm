module Shared.Css exposing (molecules)


molecules =
    { button =
        { base = "font-bold py-2 px-4 rounded no-underline"
        , primary = "bg-blue hover:bg-blue-dark text-white"
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
