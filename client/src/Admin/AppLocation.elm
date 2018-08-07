module Admin.AppLocation exposing (..)

import Admin.Routes as Routes exposing (Route)
import Navigation


type alias AppLocation =
    { hash : String
    , query : String
    , route : Route
    }


navigationLocationToAppLocation : Navigation.Location -> AppLocation
navigationLocationToAppLocation location =
    { hash = location.hash
    , query = location.search
    , route = Routes.parseLocation location
    }
