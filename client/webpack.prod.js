const webpack = require("webpack")
const path = require("path")
const merge = require("webpack-merge")
const UglifyJsPlugin = require("uglifyjs-webpack-plugin")
const CleanWebpackPlugin = require("clean-webpack-plugin")
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin")
const common = require("./webpack.base")

let outputPath = path.join(__dirname, "dist-prod", "a")

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
	module: {
		rules: [

			{
				test: /\.elm$/,
				exclude: [/elm-stuff/, /node_modules/],
				use: {
					loader: "elm-webpack-loader",
					options: {
						
					},
				},
			},

		]
	},
	plugins: [
		new CleanWebpackPlugin(outputPath),
	]
}

module.exports = merge(common, prodConfig)
