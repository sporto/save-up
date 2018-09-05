const webpack = require("webpack")
const merge = require("webpack-merge")
const CleanWebpackPlugin = require("clean-webpack-plugin")
const path = require("path")
const common = require("./webpack.base")

let outputPath = path.join(__dirname, "dist-dev", "a")

let devConfig = {

	output: {
		filename: "[name].js",
		path: outputPath,
	},
	plugins: [
		new CleanWebpackPlugin(outputPath),
	],
	devServer: {
		contentBase: outputPath,
		port: 8080,
	},
}

module.exports = merge(common, devConfig)
