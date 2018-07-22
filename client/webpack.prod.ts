import * as webpack from "webpack"
import * as path from "path"
import * as merge from "webpack-merge"
import common from "./webpack.config"

let outputPath = path.join(__dirname, "dist")

let prodConfig: webpack.Configuration = {
    mode: "production",
    output: {
        filename: "[name]-[hash].js",
        path: outputPath,
    }
}

export default merge(common, prodConfig)
