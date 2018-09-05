const webpack = require("webpack")
const path = require("path")
const merge = require("webpack-merge")
const UglifyJsPlugin = require("uglifyjs-webpack-plugin")
const CleanWebpackPlugin = require("clean-webpack-plugin")
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin")

import common from "./webpack.base"

let outputPath = path.join(__dirname, "dist", "a")

let prodConfig = {
	mode: "production",
	output: {
		filename: "[name]-[hash].js",
		path: outputPath,
	},
	optimization: {
		minimizer: [
			new UglifyJsPlugin({
				cache: true,
				parallel: true,
				sourceMap: false,
			}),
			new OptimizeCSSAssetsPlugin({}),
		],
	},
	plugins: [
		new CleanWebpackPlugin(outputPath),
	]
}

module.exports = merge(common, prodConfig)
