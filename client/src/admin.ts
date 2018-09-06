require("@fortawesome/fontawesome-free/css/all.css")
// @import '~@fortawesome/fontawesome-free/scss/fontawesome'; 

require("./styles.css")

//@ts-ignore
import * as Elm from "./Admin.elm"
import app from "./app"

app(Elm.Elm.Admin)
