const elmSource = __dirname;

const config = {
    entry: {
        admin: "./src/admin.ts",
    },
    output: {
        filename: "[name].js",
        path: __dirname + "/../api/static/bundles",
    },
    module: {
        rules: [{
            test: /\.elm$/,
            exclude: [/elm-stuff/, /node_modules/],
            use: {
                loader: "elm-webpack-loader",
                options: {
                    // cwd: elmSource,
                }
            }
        }]
    },
    mode: "development",
};


module.exports = config;
