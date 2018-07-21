import * as Cookies from "js-cookie"
import * as jwtDecode from "jwt-decode"
import { Option, None, Some } from "space-lift"
import { KIC_TOKEN } from "./constants"

export function getToken(): Option<string> {
    let token = Cookies.get(KIC_TOKEN)

    if (token == null) {
        return None
    } else {
        return Some(token)
    }
}

export function getTokenDecoded(): Option<Token> {
    return getToken()
        .flatMap(decodeToken)
}

export function decodeToken(token: string): Option<Token> {
    let decoded: Token = jwtDecode(token)
    return Some(decoded)
}

export function removeToken(): void {
    Cookies.remove(KIC_TOKEN)
}

export function storeToken(token: string): void {
    Cookies.set(KIC_TOKEN, token)
}

