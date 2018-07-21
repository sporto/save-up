//@ts-ignore
import * as App from "./elm-out/app.js"
import * as sessions from "./services/sessions"

interface SignUpApp {
    ports: {
        toJsUseToken: {
            subscribe(f: (t: string) => void): void,
        },
    },
}

sessions.proceedIfSignedOut(function() {
    const flags = {}
    const element = document.getElementById("app")
    const app: SignUpApp = App.Elm.SignUp.init(element, flags)
    
    app.ports.toJsUseToken.subscribe(sessions.newSession)
})
