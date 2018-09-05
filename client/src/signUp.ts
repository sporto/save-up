require("./styles.css")

//@ts-ignore
import * as Elm from "./SignUp.elm"
import auth from "./auth"

auth(Elm.Elm.SignUp)
