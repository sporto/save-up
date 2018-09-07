require("./styles.css")

//@ts-ignore
import * as Elm from "./Public.elm"

import * as sessions from "./services/sessions"
import getConfig from "./services/config"

interface Elm {
	init(args: ElmArgs): PublicApp
}

interface ElmArgs 
	{node: HTMLElement | null, flags: PublicFlags}

interface PublicApp {
	ports: {
		toJsUseToken: {
			subscribe(f: (t: string) => void): void,
		},
	},
}

sessions.proceedIfSignedOut(function() {
	let config = getConfig()

	const flags: PublicFlags = {
		apiHost: config.apiHost,
	}

	const node = document.getElementById("app")

	const app: PublicApp = Elm.Elm.Public.init({node, flags})

	app.ports.toJsUseToken.subscribe(sessions.newSessionWithToken)
})

