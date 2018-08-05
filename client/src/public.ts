import * as sessions from "./services/sessions"
import getConfig from "./services/config"

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
		let config = getConfig()

		const flags: PublicFlags = {
			apiHost: config.apiHost,
		}

		const node = document.getElementById("app")

		const app: PublicApp = Elm.init({node, flags})

		app.ports.toJsUseToken.subscribe(sessions.newSession)
	})
}
