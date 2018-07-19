import * as App from "../elm-dist/app.js"
import processToken from "./services/processToken.ts"

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

app.ports.toJsUseToken.subscribe(processToken)
