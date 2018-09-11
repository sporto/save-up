const invariant = require("invariant")
const webpack = require("webpack")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")
const HtmlWebpackPlugin = require("html-webpack-plugin")
const path = require("path")

const API_HOST = process.env.API_HOST

const ASSETS_PATH = "/a"
const COMMON = "common"
const DEV_MODE = process.env.NODE_ENV !== "production"
const ENTRY_ADMIN = "admin"
const ENTRY_GRAPHIQL = "graphiql"
const ENTRY_INVESTOR = "investor"
const ENTRY_PUB = "pub"
const STYLES = "styles"

invariant(API_HOST, "API_HOST must be defined")

let baseConfig = {
	entry: {
		[ENTRY_ADMIN]: "./src/admin.ts",
		[ENTRY_GRAPHIQL]: "./src/graphiql.ts",
		[ENTRY_INVESTOR]: "./src/investor.ts",
		[ENTRY_PUB]: "./src/public.ts",
	},
	output: {
		publicPath: ASSETS_PATH,
	},
	optimization: {
		splitChunks: {
			cacheGroups: {
				styles: {
					name: STYLES,
					test: /\.css$/,
					chunks: "all",
				},
				commons: {
					test: /[\\/]node_modules[\\/]/,
					name: COMMON,
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
		extensions: [".ts", ".js"],
	},
	plugins: [
		new webpack.DefinePlugin({
			API_HOST: JSON.stringify(API_HOST),
		}),
		new MiniCssExtractPlugin({
			filename: DEV_MODE ? "[name].css" : "[name].[hash].css",
		}),
		new HtmlWebpackPlugin({
			chunks: [COMMON, STYLES, ENTRY_GRAPHIQL],
			title: "Graphiql",
			filename: ENTRY_GRAPHIQL + "/index.html",
			template: "src/graphiql.html",
		}),
		new HtmlWebpackPlugin({
			chunks: [COMMON, STYLES, ENTRY_PUB],
			title: "Public",
			filename: ENTRY_PUB + "/index.html",
			template: "src/application.html",
		}),
		new HtmlWebpackPlugin({
			chunks: [COMMON, STYLES, ENTRY_ADMIN],
			title: "Admin",
			filename: ENTRY_ADMIN + "/index.html",
			template: "src/application.html",
		}),
		new HtmlWebpackPlugin({
			chunks: [COMMON, STYLES, ENTRY_INVESTOR],
			title: "Investor",
			filename: ENTRY_INVESTOR + "/index.html",
			template: "src/application.html",
		}),
	],
}

module.exports = baseConfig
