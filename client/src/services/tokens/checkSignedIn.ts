import getToken from "./getToken"
import redirectToEntry from "./redirectToEntry"

export default function run(): void {
    let token = getToken()
    redirectToEntry(token)
}
