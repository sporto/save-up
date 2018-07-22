import * as webpack from "webpack"
import * as path from "path"
import * as merge from "webpack-merge"
import * as CleanWebpackPlugin from "clean-webpack-plugin"
import common from "./webpack.config"

let outputPath = path.join(__dirname, "dist")

let prodConfig: webpack.Configuration = {
    mode: "production",
    output: {
        filename: "[name]-[hash].js",
        path: outputPath,
    },
    plugins: [
        new CleanWebpackPlugin(outputPath),
    ]
}

export default merge(common, prodConfig)
