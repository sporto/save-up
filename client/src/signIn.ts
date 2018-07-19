import * as App from "../elm-dist/app.js"
import processToken from "./services/processToken.ts"

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

app.ports.toJsUseToken.subscribe(processToken)
