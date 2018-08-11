import * as webpack from "webpack"
import * as path from "path"
import * as merge from "webpack-merge"
import * as CleanWebpackPlugin from "clean-webpack-plugin"
import { BundleAnalyzerPlugin } from "webpack-bundle-analyzer"

import common from "./webpack.base"

let outputPath = path.join(__dirname, "dist", "app")

let prodConfig: webpack.Configuration = {
    mode: "production",
    output: {
        filename: "[name]-[hash].js",
        path: outputPath,
    },
    plugins: [
		new CleanWebpackPlugin(outputPath),
		new BundleAnalyzerPlugin({analyzerMode: "disabled", generateStatsFile: true}),
    ]
}

export default merge(common, prodConfig)
