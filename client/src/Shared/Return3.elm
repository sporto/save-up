module Shared.Return3 exposing
    ( andThen
    , mapAll
    , mapModel
    , mapMsg
    , noOp
    )

import Shared.Actions as Actions


type alias R model msg =
    ( model, Cmd msg, Actions.Actions msg )


noOp : model -> R model msg
noOp model =
    ( model, Cmd.none, Actions.none )


mapModel : (model1 -> model2) -> R model1 msg -> R model2 msg
mapModel mapModelFn ( model, cmd, action ) =
    ( mapModelFn model, cmd, action )


mapMsg : (msg1 -> msg2) -> R model1 msg1 -> R model1 msg2
mapMsg mapMsgFn ( model, cmd, action ) =
    ( model, Cmd.map mapMsgFn cmd, Actions.map mapMsgFn action )


mapAll : (model1 -> model2) -> (msg1 -> msg2) -> R model1 msg1 -> R model2 msg2
mapAll mapModelFn mapMsgFn ( model, cmd, action ) =
    ( mapModelFn model, Cmd.map mapMsgFn cmd, Actions.map mapMsgFn action )


andThen : (model -> R model msg) -> R model msg -> R model msg
andThen nextFunction ( model, cmd, actions ) =
    let
        ( newModel, newCmd, newAction ) =
            nextFunction model
    in
    ( newModel, Cmd.batch [ cmd, newCmd ], Actions.batch [ actions, newAction ] )
