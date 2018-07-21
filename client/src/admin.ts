//@ts-ignore
import * as App from "./elm-out/app.js"
import * as sessions from "./services/sessions"
import hookCommonPorts from "./services/hookCommonPorts"

sessions.proceedIfSignedIn(function(_token) {
    const flags = {}
    const element = document.getElementById("app")
    const app = App.Elm.Admin.init(element, flags)

    hookCommonPorts(app.ports)
})
