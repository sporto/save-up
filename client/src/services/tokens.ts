import * as Cookies from "js-cookie"
import * as jwtDecode from "jwt-decode"
import { Option, None, Some } from "space-lift"
import { KIC_TOKEN } from "./constants"

export function getToken(): Option<string> {
    let token = Cookies.get(KIC_TOKEN)

    return (token == null) 
        ? None
        : Some(token)
}

export function getTokenDecoded(): Option<Token> {
    return getToken()
        .flatMap(decodeToken)
}

export function decodeToken(token: string): Option<Token> {
    let decoded: Token = jwtDecode(token)
    return Some(decoded)
}

export function removeToken(): boolean {
    Cookies.remove(KIC_TOKEN)
    return true
}

export function storeToken(token: string): boolean {
    Cookies.set(KIC_TOKEN, token)
    return true
}

