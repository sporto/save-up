import * as App from "../elm-dist/app.js"

import checkSignedIn from "./services/tokens/checkSignedIn"
import processNewToken from "./services/tokens/processNewToken"

interface SignInApp {
    ports: {
        toJsUseToken: {
            subscribe(f: (t: string) => void): void,
        },
    },
}

const flags = {}
const element = document.getElementById("app")
const app: SignInApp = App.Elm.SignIn.init(element, flags)

app.ports.toJsUseToken.subscribe(processNewToken)

checkSignedIn()
