// const elmSource = __dirname;

import * as path from "path"
import * as webpack from "webpack"
import * as AssetsPlugin from "assets-webpack-plugin"

let bundleDir = path.join(__dirname, "../api", "static", "bundles")

let assetsPluginInstance = new AssetsPlugin({
    path: bundleDir,
})

const config: webpack.Configuration = {
    entry: {
        admin: "./src/admin.ts",
    },
    output: {
        filename: "[name]-[chunkhash].js",
        path: bundleDir,
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

export default config
