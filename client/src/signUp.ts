//@ts-ignore
import * as App from "./elm-out/app.js"
import processNewToken from "./services/tokens/processNewToken"

interface SignUpApp {
    ports: {
        toJsUseToken: {
            subscribe(f: (t: string) => void): void,
        },
    },
}

const flags = {}
const element = document.getElementById("app")
const app: SignUpApp = App.Elm.SignUp.init(element, flags)

app.ports.toJsUseToken.subscribe(processNewToken)
