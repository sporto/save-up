import * as webpack from "webpack"
import * as merge from "webpack-merge"
import common from "./webpack.config"

let devConfig: webpack.Configuration = {
    mode: "development",
}

export default merge(common, devConfig)
