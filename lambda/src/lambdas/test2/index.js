exports.handler = (event, context, callback) => {
  console.log('Handler start')

  callback(null, {
      statusCode: 200,
      body: 'Hello world.'
  })
}
