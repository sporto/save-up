import * as Cookies from "js-cookie"
import { Option, None, Some } from "space-lift"
import { KIC_TOKEN } from "../constants"

export default function run(): Option<string> {
    let token = Cookies.get(KIC_TOKEN)

    if (token == null) {
        return None
    } else {
        return Some(token)
    }
}
