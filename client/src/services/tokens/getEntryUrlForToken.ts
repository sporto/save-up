export default function getEntryUrlForToken(token: Token): string {
    return token.role == "admin"
        ? "/admin"
        : "/investor"
}
