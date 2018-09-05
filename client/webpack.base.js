const invariant = require("invariant")
const webpack = require("webpack")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")
const HtmlWebpackPlugin = require("html-webpack-plugin")
const path = require("path")

const API_HOST = process.env.API_HOST

const ENTRY_ADMIN = "admin"
const ENTRY_INVESTOR = "investor"
const ENTRY_SIGN_IN = "sign-in"
const ENTRY_SIGN_UP = "sign-up"
const ENTRY_GRAPHIQL = "graphiql"
const COMMON = "common"
const STYLES = "styles"
const ASSETS_PATH = "/a"
const DEV_MODE = process.env.NODE_ENV !== "production"

invariant(API_HOST, "API_HOST must be defined")

let baseConfig = {
	entry: {
		[ENTRY_GRAPHIQL]: "./src/graphiql.ts",
		[ENTRY_SIGN_IN]: "./src/signIn.ts",
		[ENTRY_SIGN_UP]: "./src/signUp.ts",
		[ENTRY_ADMIN]: "./src/admin.ts",
		[ENTRY_INVESTOR]: "./src/investor.ts",
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
				test: /\.ts$/,
				use: {
					loader: "ts-loader",
				},
			},

			{
				test: /\.elm$/,
				exclude: [/elm-stuff/, /node_modules/],
				use: {
					loader: "elm-webpack-loader",
					options: {
						cwd: __dirname,
					},
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
			}

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
			filename: DEV_MODE ? "[name].css" :  "[name].[hash].css",
		}),
		new HtmlWebpackPlugin({
			chunks: [COMMON, STYLES, ENTRY_GRAPHIQL],
			title: "Graphiql",
			filename: ENTRY_GRAPHIQL + "/index.html",
			template: "src/graphiql.html",
		}),
		new HtmlWebpackPlugin({
			chunks: [COMMON, STYLES, ENTRY_SIGN_IN],
			title: "Sign In",
			filename: ENTRY_SIGN_IN + "/index.html",
			template: "src/application.html",
		}),
		new HtmlWebpackPlugin({
			chunks: [COMMON, STYLES, ENTRY_SIGN_UP],
			title: "Sign Up",
			filename: ENTRY_SIGN_UP + "/index.html",
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
