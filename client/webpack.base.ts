import * as webpack from "webpack"
import * as HtmlWebpackPlugin from "html-webpack-plugin"

// let publicPath = "/webpack/"

const ENTRY_SIGN_IN = "sign-in"
const ENTRY_SIGN_UP = "sign-up"
const ENTRY_ADMIN = "admin"
const ENTRY_INVESTOR = "investor"
const COMMON = "common"

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
                //     name: 'vendors',
                //     chunks: 'all'
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
                        // cwd: elmSource,
                    },
                },
            },
        ],
    },
    resolve: {
        extensions: [".ts", ".js"]
    },
    plugins: [
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
