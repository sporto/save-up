import * as jwtDecode from "jwt-decode"

// e.g. eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InNhbUBzYW1wbGUuY29tIiwibmFtZSI6IlNhbSIsInJvbGUiOiJYWUEiLCJ1c2VySWQiOjF9.2FziBFKqahAl18Do_YUEjoHna7plI-M6EpYPx5Wt4Cc=


export default function run(token: string): Token {
    return jwtDecode(token)
}
