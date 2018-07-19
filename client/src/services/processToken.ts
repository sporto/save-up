import * as Cookies from "js-cookie"
import * as jwtDecode from "jwt-decode"

// e.g. eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InNhbUBzYW1wbGUuY29tIiwibmFtZSI6IlNhbSIsInJvbGUiOiJYWUEiLCJ1c2VySWQiOjF9.2FziBFKqahAl18Do_YUEjoHna7plI-M6EpYPx5Wt4Cc=

interface Token {
    role: string,
}

export default function run(token: string): void {
    Cookies.set("kic-token", token)

    let decoded: Token = jwtDecode(token)

    let path = decoded.role == "admin"
        ? "/admin"
        : "/investor"

    window.location.href = path
}
