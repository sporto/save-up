module Shared.Return exposing (andThen, mapBoth, mapModel)


type alias R model msg =
    ( model, Cmd msg )


mapModel : (model1 -> model2) -> R model1 msg -> R model2 msg
mapModel mapModelFn ( model, cmd ) =
    ( mapModelFn model, cmd )


mapBoth : (model1 -> model2) -> (msg1 -> msg2) -> R model1 msg1 -> R model2 msg2
mapBoth mapModelFn tagCmd ( model, cmd ) =
    ( mapModelFn model, Cmd.map tagCmd cmd )


andThen : (model -> R model msg) -> R model msg -> R model msg
andThen nextFunction ( model, cmd ) =
    let
        ( newModel, newCmd ) =
            nextFunction model
    in
    ( newModel, Cmd.batch [ cmd, newCmd ] )
