import * as tokens from "./tokens"
import { SIGN_IN_PATH } from "./constants"

export function newSession(token: string): void {
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
        ? "/admin"
        : "/investor"
}

export function proceedIfSignedIn(callback: (token: Token) => void): void {
    let result = tokens.getTokenDecoded()
        .map(callback)

    if (!result.isDefined()) {
        redirectToSignIn()
    }
}

export function proceedIfSignedOut(callback: () => void): void {
    let result = tokens.getToken()
        .map(token => redirectToEntry(token))

    if (!result.isDefined()) callback()
}

export function signOut() {
    tokens.removeToken()
    redirectToSignIn()
}
