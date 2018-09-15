//@ts-ignore
import styles from "./styles.css"
// const styles = require("./styles.css")

import * as session from "./sessions"
import getConfig from "./config"

// @ts-ignore
import Elm from "./App.elm"

let token = session.getToken()
let config = getConfig()
let apiHost = config.apiHost

let node = document.getElementById('app')

let flags = {
	apiHost,
	token,
}

let app: Elm.App.App = Elm.App.init({ node, flags })

app.ports
	.toJsStoreToken
	.subscribe(session.storeToken)

app.ports
	.toJsRemoveToken
	.subscribe(session.removeToken)


