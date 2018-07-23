import * as invariant from "invariant"
import * as sessions from "./sessions"

export default function run(ports: CommonPorts) {
    invariant(ports.toJsSignOut, "Missing toJsSignOut")

    ports.toJsSignOut.subscribe(sessions.signOut)
}
