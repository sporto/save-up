// const elmSource = __dirname;

import * as path from "path"
import * as webpack from "webpack"
import * as AssetsPlugin from "assets-webpack-plugin"
import * as merge from "webpack-merge"

const DEVELOPMENT = "development"
const PRODUCTION = "production"
let TARGET = process.env.NODE_ENV || DEVELOPMENT

let outputPath = path.join(__dirname, "../api", "static", "bundles")

let assetsPluginInstance = new AssetsPlugin({
    path: outputPath,
})

let publicPath = "/webpack/"

let baseConfig: webpack.Configuration = {
    entry: {
        admin: "./src/admin.ts",
    },
    output: {
        filename: "[name].js",
        path: outputPath,
        publicPath: publicPath,
    },
    module: {
        rules: [
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
    mode: "development",
    plugins: [assetsPluginInstance],
}

let devConfig = {}

let prodConfig: webpack.Configuration = {
    mode: "production",
    output: {
        filename: "[name]-[hash].js",
    }
}

let config = null

if (TARGET === DEVELOPMENT) {
    config = merge(baseConfig, devConfig)
} else {
    config = merge(baseConfig, prodConfig)
}
  

export default config
