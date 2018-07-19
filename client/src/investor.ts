import * as App from "../elm-dist/app.js";

// console.log(App)

const flags = {}
const element = document.getElementById("app")
const app = App.Elm.Investor.init(element, flags)
