import getToken from "./getToken"
import redirectToEntry from "./redirectToEntry"

export default function run(): void {
    getToken().map(redirectToEntry)
}
