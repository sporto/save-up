import * as tokens from "./tokens"
import { SIGN_IN_PATH } from "./constants"
import getConfig from "./config"

export function newSessionWithToken(token: string): void {
	tokens.storeToken(token)
	redirectToEntry(token)
}

export function redirectToEntry(token: string): void {
	tokens.decodeToken(token)
		.map(
			decoded => window.location.href = getEntryUrlForToken(decoded)
		)
}

export function redirectToSignIn() {
	window.location.href = SIGN_IN_PATH
}

export function getEntryUrlForToken(token: Token): string {
	return token.role == "admin"
		? "/app/admin"
		: "/app/investor"
}

export function proceedIfSignedIn(callback: (token: Token) => void): void {
	let maybeToken = tokens.getTokenDecoded()

	if (maybeToken.isDefined()) {
		maybeToken.map(callback)
	} else {
		console.log("No token found - redirecting")
		redirectToSignIn()
	}
}

export function proceedIfSignedOut(callback: () => void): void {
	let maybeToken = tokens.getToken()

	if (maybeToken.isDefined()) {
		maybeToken.map(token => redirectToEntry(token))
	} else {
		console.log("No token found - render page")
		callback()
	}
}

export function signOut() {
	tokens.removeToken()
	redirectToSignIn()
}
