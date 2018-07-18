import App from "../elm-dist/admin.js";

// console.log(App)

const flags = {};
const element = document.getElementById("app");
const app = App.Elm.Admin.init(element, flags);
