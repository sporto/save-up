import * as invariant from "invariant"
import * as webpack from "webpack"
import * as HtmlWebpackPlugin from "html-webpack-plugin"
import * as path from "path"

const API_HOST = process.env.API_HOST
const COGNITO_REGION = process.env.COGNITO_REGION
const COGNITO_APP_CLIENT_ID = process.env.COGNITO_APP_CLIENT_ID
const COGNITO_USER_POOL_ID = process.env.COGNITO_USER_POOL_ID

const ENTRY_ADMIN = "admin"
const ENTRY_INVESTOR = "investor"
const ENTRY_SIGN_IN = "sign-in"
const ENTRY_SIGN_UP = "sign-up"
const COMMON = "common"

invariant(API_HOST, "API_HOST must be defined")
invariant(COGNITO_REGION, "COGNITO_REGION must be defined")
invariant(COGNITO_APP_CLIENT_ID, "COGNITO_APP_CLIENT_ID must be defined")
invariant(COGNITO_USER_POOL_ID, "COGNITO_USER_POOL_ID must be defined")

let baseConfig: webpack.Configuration = {
	entry: {
		[ENTRY_SIGN_IN]: "./src/signIn.ts",
		[ENTRY_SIGN_UP]: "./src/signUp.ts",
		[ENTRY_ADMIN]: "./src/admin.ts",
		[ENTRY_INVESTOR]: "./src/investor.ts",
	},
	optimization: {
		splitChunks: {
			// chunks: "all",
			cacheGroups: {
				common: {
					name: COMMON,
					chunks: "initial",
				},
				// vendor: {
				//     test: /[\\/]node_modules[\\/]/,
				//     name: "vendors",
				//     chunks: "all"
				// },
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
		],
	},
	resolve: {
		extensions: [".ts", ".js"],
	},
	plugins: [
	  new webpack.DefinePlugin({
		API_HOST: JSON.stringify(API_HOST),
		COGNITO_APP_CLIENT_ID: JSON.stringify(COGNITO_APP_CLIENT_ID),
		COGNITO_REGION: JSON.stringify(COGNITO_REGION),
		COGNITO_USER_POOL_ID: JSON.stringify(COGNITO_USER_POOL_ID),
	  }),
	  new HtmlWebpackPlugin({
		  chunks: [COMMON, ENTRY_SIGN_IN],
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
