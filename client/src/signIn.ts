require("./styles.css")

//@ts-ignore
import * as Elm from "./SignIn.elm"
import auth from "./auth"

auth(Elm.Elm.SignIn)
