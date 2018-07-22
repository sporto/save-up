import * as sessions from "./services/sessions"

interface SignInApp {
    ports: {
        toJsUseToken: {
            subscribe(f: (t: string) => void): void,
        },
    },
}

export default function pubic(App) {

    sessions.proceedIfSignedOut(function() {
        const flags: PublicFlags = {
            apiHost: "http://localhost:4010/sign-in",
        }

        const node = document.getElementById("app")

        const app: SignInApp = App.init({node, flags})

        app.ports.toJsUseToken.subscribe(sessions.newSession)
    })

}
