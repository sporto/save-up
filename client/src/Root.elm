module Root exposing (Model, Msg(..), MsgAdmin(..), MsgInvestor(..), MsgPublic(..), Page(..), PageAdmin(..), PageInvestor(..), PagePublic(..))

import Admin.Pages.Account
import Admin.Pages.Home
import Admin.Pages.Invite
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Investor.Pages.Home
import Public.Pages.Invitation as Invitation
import Public.Pages.SignIn as SignIn
import Public.Pages.SignUp as SignUp
import Shared.AppLocation exposing (AppLocation)
import Shared.Globals exposing (..)
import Url exposing (Url)


type alias Model =
    { authentication : Maybe Authentication
    , flags : Flags
    , currentLocation : AppLocation
    , navKey : Nav.Key
    , page : Page
    }


type Page
    = Page_Admin Authentication PageAdmin
    | Page_Investor Authentication PageInvestor
    | Page_Public PagePublic
    | Page_NotFound


type PagePublic
    = PagePublic_Invitation Invitation.Model
    | PagePublic_SignIn SignIn.Model
    | PagePublic_SignUp SignUp.Model


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
    | Msg_Admin MsgAdmin
    | Msg_Investor MsgInvestor
    | Msg_Public MsgPublic


type MsgPublic
    = PageInvitationMsg Invitation.Msg
    | PageSignInMsg SignIn.Msg
    | PageSignUpMsg SignUp.Msg


type MsgAdmin
    = PageAdminAccountMsg Admin.Pages.Account.Msg
    | PageAdminHomeMsg Admin.Pages.Home.Msg
    | PageAdminInviteMsg Admin.Pages.Invite.Msg


type MsgInvestor
    = PageInvestorHomeMsg Investor.Pages.Home.Msg
