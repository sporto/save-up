module Admin.Navigation exposing (setRoute, setUrl)

import Admin.Routes as Routes
import Navigation


setRoute : Routes.Route -> Cmd msg
setRoute route =
    route |> Routes.pathFor |> setUrl


setUrl : String -> Cmd msg
setUrl url =
    Navigation.newUrl url
