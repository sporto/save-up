const webpack = require("webpack")
const merge = require("webpack-merge")
const CleanWebpackPlugin = require("clean-webpack-plugin")
const path = require("path")
const common = require("./webpack.base")

let outputPath = path.join(__dirname, "dist-dev", "a")

let devConfig = {
	mode: "development",
	output: {
		filename: "[name].js",
		path: outputPath,
	},
	plugins: [
		new CleanWebpackPlugin(outputPath),
	],
	devServer: {
		port: 8080,
		historyApiFallback: {
			rewrites: [
				{ from: /^\/a\/pub/, to: '/a/pub' },
				{ from: /^\/a\/admin/, to: '/a/admin' },
				{ from: /^\/a\/investor/, to: '/a/investor' },
			],
		},
	},
}

module.exports = merge(common, devConfig)
