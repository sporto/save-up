module Admin.AppLocation exposing (AppLocation, fromUrl)

import Admin.Routes as Routes exposing (Route)
import Url exposing (Url)


type alias AppLocation =
    { rawUrl : Url
    , route : Route
    }


fromUrl : Url -> AppLocation
fromUrl url =
    { rawUrl = url
    , route = Routes.parseUrl url
    }
