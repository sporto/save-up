import * as tokens from "./tokens"
import { SIGN_IN_PATH } from "./constants"
import getConfig from "./config"

export function newSessionWithToken(token: string): void {
	tokens.storeToken(token)
	redirectToEntry(token)
}

export function redirectToEntry(token: string): void {
	let tokenData = tokens.decodeToken(token)

	window.location.href = getEntryUrlForTokenData(tokenData)
}

export function redirectToSignIn() {
	window.location.href = SIGN_IN_PATH
}

export function getEntryUrlForTokenData(tokenData: TokenData): string {
	return tokenData.role == "admin"
		? "/a/admin"
		: "/a/investor"
}

export function proceedIfSignedIn(callback: (tokenAndData: TokenAndData) => void): void {
	tokens
		.getTokenDecoded()
		.fold(
			() => {
				console.log("No token found - redirecting")
				redirectToSignIn()
			},
			(tokenAndData: TokenAndData) => {
				callback(tokenAndData)
			}
		)
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
