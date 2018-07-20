import * as Cookies from "js-cookie"
import { KIC_TOKEN } from "../constants"

export default function run(): string | undefined {
    return Cookies.get(KIC_TOKEN)
}
