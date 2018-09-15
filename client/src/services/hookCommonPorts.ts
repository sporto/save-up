import * as invariant from "invariant"
import * as sessions from "./sessions"

import { Elm } from "../Admin/index"

export default function run(app: Elm.Admin.App) {
	invariant(app.ports.toJsSignOut, "Missing toJsSignOut")

	app.ports.toJsSignOut.subscribe(sessions.signOut)
}
