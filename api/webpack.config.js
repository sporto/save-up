const path = require("path")
const slsw = require("serverless-webpack")

module.exports = {
	entry: {
		mail: "./mail.app.ts",
	},
	resolve: {
		extensions: [
			".ts",
		],
	},
	output: {
		libraryTarget: "commonjs",
		path: path.join(__dirname, ".webpack"),
		filename: "[name].js"
	},
	target: "node",
	module: {
		rules: [
			{
				test: /\.ts$/,
				use: {
					loader: "ts-loader",
				},
			},
		]
	}
}
