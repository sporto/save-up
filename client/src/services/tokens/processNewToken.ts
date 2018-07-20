import * as Cookies from "js-cookie"
import { KIC_TOKEN } from "../constants"
import redirectToEntry from "./redirectToEntry"

export default function run(token: string): void {
    Cookies.set(KIC_TOKEN, token)
    redirectToEntry(token)
}
