const webpack = require("webpack")
const merge = require("webpack-merge")
const common = require("./webpack.base")

let devConfig = {
	devServer: {
		port: 8080,
		historyApiFallback: {
			rewrites: [
				{ from: /^\/a/, to: '/a' },
			],
		},
	},
}

module.exports = merge(common, devConfig)
