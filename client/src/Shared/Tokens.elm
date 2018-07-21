port module Shared.Tokens exposing (..)

port toJsUseToken : String -> Cmd msg

port toJsSignOut : () -> Cmd msg
