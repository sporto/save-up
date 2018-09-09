module Shared.Return exposing (mapBoth)


type alias R model msg =
    ( model, Cmd msg )


mapBoth : (model1 -> model2) -> (msg1 -> msg2) -> R model1 msg1 -> R model2 msg2
mapBoth mapModel tagCmd ( model, cmd ) =
    ( mapModel model, Cmd.map tagCmd cmd )
