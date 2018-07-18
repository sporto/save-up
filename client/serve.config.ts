import publicPath from "./webpack.config"

let config = {
    options: {
        devMiddleware: {
            publicPath,
        }
    }
}

export default config
