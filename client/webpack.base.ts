import * as invariant from "invariant"
import * as webpack from "webpack"
// @ts-ignore
import * as ExtractTextPlugin from "extract-text-webpack-plugin"
import * as HtmlWebpackPlugin from "html-webpack-plugin"
import * as path from "path"

const API_HOST = process.env.API_HOST

const ENTRY_ADMIN = "admin"
const ENTRY_INVESTOR = "investor"
const ENTRY_SIGN_IN = "sign-in"
const ENTRY_SIGN_UP = "sign-up"
const COMMON = "common"
const STYLES = "styles"

invariant(API_HOST, "API_HOST must be defined")

let baseConfig: webpack.Configuration = {
	entry: {
		[STYLES]: "./src/styles.css",
		[ENTRY_SIGN_IN]: "./src/signIn.ts",
		[ENTRY_SIGN_UP]: "./src/signUp.ts",
		[ENTRY_ADMIN]: "./src/admin.ts",
		[ENTRY_INVESTOR]: "./src/investor.ts",
	},
	optimization: {
		splitChunks: {
			cacheGroups: {
				common: {
					// test: /[\\/]node_modules[\\/]/,
					name: COMMON,
					chunks: "initial",
					enforce: true
				},
				styles: {
					name: STYLES,
					test: /\.css$/,
					chunks: "all",
					enforce: true,
				}
			},
		},
	},
	module: {
		rules: [

			{
				test: /\.ts$/,
				use: {
					loader: "ts-loader",
					options: {
						// logInfoToStdOut: true,
					},
				},
			},

			{
				test: /\.elm$/,
				exclude: [/elm-stuff/, /node_modules/],
				use: {
					loader: "elm-webpack-loader",
					options: {
						cwd: __dirname,
						files: [
							path.resolve(__dirname, "src/Main.elm"),
							path.resolve(__dirname, "src/Admin.elm"),
							path.resolve(__dirname, "src/Investor.elm"),
							path.resolve(__dirname, "src/SignIn.elm"),
							path.resolve(__dirname, "src/SignUp.elm"),
						]
					},
				},
			},

			{
				test: /\.css$/,
				use: ExtractTextPlugin.extract({
				  fallback: 'style-loader',
				  use: [
					{ loader: 'css-loader', options: { importLoaders: 1 } },
					'postcss-loader'
					]
				})
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
		new ExtractTextPlugin("styles.css"),
		new HtmlWebpackPlugin({
			chunks: [COMMON, ENTRY_SIGN_IN, "styles"],
			title: "Sign In",
			filename: "sign-in/index.html",
			template: "src/application.html",
		}),
		new HtmlWebpackPlugin({
			chunks: [COMMON, ENTRY_SIGN_UP],
			title: "Sign Ip",
			filename: "sign-up/index.html",
			template: "src/application.html",
		}),
		new HtmlWebpackPlugin({
			chunks: [COMMON, ENTRY_ADMIN],
			title: "Admin",
			filename: "admin/index.html",
			template: "src/application.html",
		}),
		new HtmlWebpackPlugin({
			chunks: [COMMON, ENTRY_INVESTOR],
			title: "Investor",
			filename: "investor/index.html",
			template: "src/application.html",
		}),
	],
}

export default baseConfig
