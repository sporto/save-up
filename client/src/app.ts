declare var API_HOST: string

//@ts-ignore
import styles from "./styles.css"
// const styles = require("./styles.css")

// @ts-ignore
// import Elm from "./App.elm"

export const TOKEN_KEY = "save-up-token"

let token = getToken()

let apiHost = API_HOST

let node = document.getElementById('app')

let flags = {
	apiHost,
	token,
}

// let app: Elm.App.App = Elm.App.init({ node, flags })

// app.ports
// 	.toJsStoreToken
// 	.subscribe(storeToken)

// app.ports
// 	.toJsRemoveToken
// 	.subscribe(removeToken)


function getToken(): string | null {
	return localStorage.getItem(TOKEN_KEY)
}

function removeToken(): void {
	return localStorage.removeItem(TOKEN_KEY)
}

function storeToken(token: string): void {
	return localStorage.setItem(TOKEN_KEY, token)
}


