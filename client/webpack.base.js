const invariant = require("invariant")
const webpack = require("webpack")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")
const HtmlWebpackPlugin = require("html-webpack-plugin")
const path = require("path")
const CleanWebpackPlugin = require("clean-webpack-plugin")

const API_HOST = process.env.API_HOST
const PROD = "production"
const DEV = "development"

let MODE = process.env.NODE_ENV == "production"
	? PROD
	: DEV

let ASSETS_PATH = "/a"
let PROD_MODE = MODE === PROD
let ENTRY_APP = "app"
let ENTRY_GRAPHIQL = "graphiql"
let STYLES = "styles"

let outputFolder = PROD_MODE
	? "dist-prod"
	: "dist-dev"

let outputPath = path.join(__dirname, outputFolder, "a")

invariant(API_HOST, "API_HOST must be defined")

let baseConfig = {
	mode: MODE,
	entry: {
		[ENTRY_APP]: "./src/app.ts",
		[ENTRY_GRAPHIQL]: "./src/graphiql.ts",
	},
	output: {
		filename: PROD_MODE ? "[name]-[hash].js" : "[hash].js",
		publicPath: ASSETS_PATH,
		path: outputPath,
	},
	optimization: {
		splitChunks: {
			cacheGroups: {
				styles: {
					name: STYLES,
					test: /\.css$/,
					chunks: "all",
				},
			},
		},
	},
	module: {
		rules: [

			{
				test: /.(ttf|otf|eot|svg|woff(2)?)(\?[a-z0-9]+)?$/,
				use: [{
					loader: 'file-loader',
					options: {
						name: '[name].[ext]',
						// outputPath: 'fonts/',
						// publicPath: '../fonts/',
					},
				}],
			},

			{
				test: /\.ts$/,
				use: {
					loader: "ts-loader",
				},
			},

			{
				test: /\.elm$/,
				exclude: [/elm-stuff/, /node_modules/],
				use: [
					{
						loader: "elm-webpack-loader",
						options: {
							cwd: __dirname,
							optimize: MODE === PROD,
						},
					}
				],
			},

			{
				test: /\.css$/,
				use: [
					{
						loader: MiniCssExtractPlugin.loader,
					},
					"css-loader",
					"postcss-loader",
				]
			},

		],
	},
	resolve: {
		extensions: [".ts", ".js", ".elm"],
	},
	plugins: [
		new CleanWebpackPlugin(outputPath),

		new webpack.DefinePlugin({
			API_HOST: JSON.stringify(API_HOST),
		}),

		new MiniCssExtractPlugin({
			filename: PROD_MODE ? "[name].[hash].css" : "[name].css",
		}),

		new HtmlWebpackPlugin({
			chunks: [STYLES, ENTRY_APP],
			title: "SaveUp",
			filename: "./index.html",
			template: "src/app.html",
		}),

		new HtmlWebpackPlugin({
			chunks: [ENTRY_GRAPHIQL],
			title: "SaveUp",
			filename: `./ ${ENTRY_GRAPHIQL}.html`,
			template: "src/app.html",
		}),
	],
}

module.exports = baseConfig
