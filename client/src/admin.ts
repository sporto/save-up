import App from "../elm-dist/app.js";

// console.log(App)

const flags = {}
const element = document.getElementById("app")
const app = App.Elm.Admin.init(element, flags)
