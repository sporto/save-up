module Root exposing (Model, Msg(..), Page(..))

import Admin
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Investor
import Notifications
import Public
import Shared.AppLocation exposing (AppLocation)
import Shared.Globals exposing (..)
import Shared.Routes as Routes
import Url exposing (Url)


type alias Model =
    { authentication : Maybe Authentication
    , flags : Flags
    , currentLocation : AppLocation
    , navKey : Nav.Key
    , notifications : Notifications.Model
    , page : Page
    }


type Page
    = Page_Admin Authentication Admin.PageAdmin
    | Page_Investor Authentication Investor.PageInvestor
    | Page_Public Public.PagePublic
    | Page_NotFound


type Msg
    = SignOut
    | ChangeRoute Routes.Route
    | OnUrlChange Url
    | OnUrlRequest UrlRequest
    | Msg_Admin Admin.Msg
    | Msg_Investor Investor.Msg
    | Msg_Public Public.Msg
    | NotificationsMsg Notifications.Msg
