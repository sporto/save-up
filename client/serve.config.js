const history = require('connect-history-api-fallback')
const convert = require('koa-connect')

module.exports = {
  add: (app, middleware, options) => {
    const historyOptions = {
      // We don't want js
      htmlAcceptHeaders: ['text/html', 'application/xhtml+xml'],
      rewrites: [
        { 
          from: /\/app\/admin.*/,
          to: '/app/admin/index.html'
        }
      ]
    }

    app.use(convert(history(historyOptions)))
  },
  devMiddleware: {
	publicPath: "/app",
  },
}
