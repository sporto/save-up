import Admin from "../elm-dist/admin.js";

const flags = {};
const element = document.getElementById("app");
const app = Admin.Main.embed(element, flags);
