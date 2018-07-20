import decodeToken from "./decodeToken"
import getEntryUrlForToken from "./getEntryUrlForToken"

export default function run(token: string): void {
    let decoded = decodeToken(token)
    let path = getEntryUrlForToken(decoded)

    window.location.href = path
}
