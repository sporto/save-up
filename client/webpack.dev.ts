import * as webpack from "webpack"
import * as merge from "webpack-merge"
import * as CleanWebpackPlugin from "clean-webpack-plugin"
import * as path from "path"
import common from "./webpack.base"

let outputPath = path.join(__dirname, "dist-dev")

let devConfig: webpack.Configuration = {
    mode: "development",
    output: {
        filename: "[name].js",
        path: outputPath,
    },
    plugins: [
        new CleanWebpackPlugin(outputPath),
    ]
}

export default merge(common, devConfig)
