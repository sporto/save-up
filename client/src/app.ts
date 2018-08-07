import * as sessions from "./services/sessions"
import hookCommonPorts from "./services/hookCommonPorts"

interface Elm {
	embed(node: HTMLElement | null, flags: Flags): App
}

interface App {
    ports: CommonPorts
}

export default function run(Elm: Elm) {

    sessions.proceedIfSignedIn(function(token) {

        const flags: Flags = {
            apiHost: API_HOST,
            token,
        }

        const node = document.getElementById("app")
        const app = Elm.embed(node, flags)

        hookCommonPorts(app.ports)
    })

}
