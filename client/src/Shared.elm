module Shared exposing (Model, Msg(..), Page(..), PageAdmin(..), PageInvestor(..))

import Admin.Pages.Account
import Admin.Pages.Home
import Admin.Pages.Invite
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Investor.Pages.Home
import Shared.AppLocation exposing (AppLocation)
import Shared.Flags as Flags exposing (Flags)
import Url exposing (Url)


type alias Model =
    { flags : Flags
    , currentLocation : AppLocation
    , key : Nav.Key
    , page : Page
    }


type Page
    = Page_Admin PageAdmin
    | Page_Investor PageInvestor
    | Page_NotFound


type PageAdmin
    = PageAdmin_Home Admin.Pages.Home.Model
    | PageAdmin_Account Admin.Pages.Account.Model
    | PageAdmin_Invite Admin.Pages.Invite.Model


type PageInvestor
    = PageInvestor_Home Investor.Pages.Home.Model


type Msg
    = SignOut
    | OnUrlChange Url
    | OnUrlRequest UrlRequest
    | PageAdminAccountMsg Admin.Pages.Account.Msg
    | PageAdminHomeMsg Admin.Pages.Home.Msg
    | PageAdminInviteMsg Admin.Pages.Invite.Msg
    | PageInvestorHomeMsg Investor.Pages.Home.Msg
