module Admin.Navigation exposing (..)

import Navigation
import Admin.Routes as Routes


setRoute : Routes.Route -> Cmd msg
setRoute route =
    route |> Routes.pathFor |> setUrl


setUrl : String -> Cmd msg
setUrl url =
    Navigation.newUrl url
