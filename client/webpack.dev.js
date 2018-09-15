const webpack = require("webpack")
const merge = require("webpack-merge")
const common = require("./webpack.base")

let devConfig = {
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
