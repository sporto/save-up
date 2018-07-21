import decodeToken from "./decodeToken"
import getEntryUrlForToken from "./getEntryUrlForToken"

export default function run(token: string): void {
    decodeToken(token)
        .map(
            decoded => window.location.href = getEntryUrlForToken(decoded)
        )
}
