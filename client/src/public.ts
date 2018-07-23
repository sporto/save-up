import * as sessions from "./services/sessions"

interface Elm {
    init(args: Args): PublicApp
}

interface Args {
    node: HTMLElement | null,
    flags: PublicFlags,
}

interface PublicApp {
    ports: {
        toJsUseToken: {
            subscribe(f: (t: string) => void): void,
        },
    },
}

export default function pubic(Elm: Elm) {

    sessions.proceedIfSignedOut(function() {
        const flags: PublicFlags = {
            apiHost: API_HOST,
        }

        const node = document.getElementById("app")

        const app: PublicApp = Elm.init({node, flags})

        app.ports.toJsUseToken.subscribe(sessions.newSession)
    })

}
