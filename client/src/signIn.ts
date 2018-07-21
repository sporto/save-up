//@ts-ignore
import * as App from "./elm-out/app.js"

import * as sessions from "./services/sessions"

interface SignInApp {
    ports: {
        toJsUseToken: {
            subscribe(f: (t: string) => void): void,
        },
    },
}

sessions.proceedIfSignedOut(function() {
    const flags = {}
    const element = document.getElementById("app")
    const app: SignInApp = App.Elm.SignIn.init(element, flags)
    
    app.ports.toJsUseToken.subscribe(sessions.newSession)
})
