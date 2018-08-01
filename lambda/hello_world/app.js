

let response;


exports.lambda_handler = (event, context, callback) => {
    // try {
    //     const ret = await axios(url);
    //     response = {
    //         'statusCode': 200,
    //         'body': JSON.stringify({
    //             message: 'hello world',
    //             location: ret.data.trim()
    //         })
    //     }
    // }
    // catch (err) {
    //     console.log(err);
    //     callback(err, null);
    // }

    let response = {
      statusCode: 200,
      'body': JSON.stringify({
          message: 'hello world',
      })
    }

    callback(null, response)
};
