const webpack = require("webpack")
const merge = require("webpack-merge")
const UglifyJsPlugin = require("uglifyjs-webpack-plugin")
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin")
const common = require("./webpack.base")

let prodConfig = {
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
}

module.exports = merge(common, prodConfig)
