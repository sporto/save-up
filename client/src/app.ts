import * as sessions from "./services/sessions"
import hookCommonPorts from "./services/hookCommonPorts"

export default function run(App) {

    sessions.proceedIfSignedIn(function(token) {

        const flags: Flags = {
            apiHost: "http://localhost:4010/sign-in",
            token,
        }

        const node = document.getElementById("app")
        const app = App.init({node, flags})

        hookCommonPorts(app.ports)
    })

}
