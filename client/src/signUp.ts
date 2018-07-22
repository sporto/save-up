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
    const flags: PublicFlags = {
        apiHost: "http://localhost:4010/sign-in",
    }

    const node = document.getElementById("app")

    const app: SignUpApp = App.Elm.SignUp.init({node, flags})

    app.ports.toJsUseToken.subscribe(sessions.newSession)
})
