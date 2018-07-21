//@ts-ignore
import * as App from "./elm-out/app.js"
import * as sessions from "./services/sessions"
import hookCommonPorts from "./services/hookCommonPorts"

sessions.proceedIfSignedIn(function(token) {

    const flags = {}
    const element = document.getElementById("app")
    const app = App.Elm.Investor.init(element, flags)
    
    hookCommonPorts(app.ports)
    

})

