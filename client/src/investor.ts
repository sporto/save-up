//@ts-ignore
import * as App from "./elm-out/app.js"

// console.log(App)

const flags = {}
const element = document.getElementById("app")
const app = App.Elm.Investor.init(element, flags)
