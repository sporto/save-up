import * as sessions from "./services/sessions"
import getConfig from "./services/config"

interface Elm {
	embed(node: HTMLElement | null, flags: PublicFlags): PublicApp
}

interface PublicApp {
	ports: {
		toJsSignUp: {
			subscribe(f: (signUp: SignUp) => void): void,
		},
		toJsUseToken: {
			subscribe(f: (t: string) => void): void,
		},
	},
}

export default function auth(Elm: Elm) {
	sessions.proceedIfSignedOut(function() {
		let config = getConfig()

		const flags: PublicFlags = {
			apiHost: config.apiHost,
		}

		const node = document.getElementById("app")

		const app: PublicApp = Elm.embed(node, flags)

		app.ports.toJsSignUp.subscribe(sessions.signUp)
		// app.ports.toJsUseToken.subscribe(sessions.newSession)
	})
}
