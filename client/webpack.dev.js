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
	module: {
		rules: [
			{
				test: /\.elm$/,
				exclude: [/elm-stuff/, /node_modules/],
				use: [
					// {
					// 	loader: "elm-hot-webpack-loader"
					// },
					{
						loader: "elm-webpack-loader",
						options: {
							cwd: __dirname,
						},
					}
				],
			},
		],
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
