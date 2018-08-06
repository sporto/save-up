"use strict";

// ***** This handler is used only in local development, for mocking the OPTIONS responses
// ***** This enables API Tests to pass CORS tests when running locally
exports.handler = (event, context, callback) => {
  callback(null, {
    statusCode: 200,
    headers: {
      "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key",
      "Access-Control-Allow-Methods": "POST, GET, PUT, DELETE",
      "Access-Control-Allow-Origin": "*"
    },
    body: ""
  });
};
