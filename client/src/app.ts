// @ts-ignore
import Elm from './App.elm'

import * as Cookies from "js-cookie"

export const TOKEN_KEY = "save-up-token"

let token = Cookies.get(TOKEN_KEY)

let apiHost = API_HOST

let node = document.getElementById('app')

let flags = {
	apiHost,
	token,
}

let app: Elm.App.App = Elm.App.init({ node, flags })




function removeToken(): boolean {
	Cookies.remove(TOKEN_KEY)
	return true
}

function storeToken(token: string): boolean {
	Cookies.set(TOKEN_KEY, token)
	return true
}


