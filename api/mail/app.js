"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// @ts-ignore
const mjml2html = require("mjml");
const aws = require("aws-sdk");
const nunjucks = require("nunjucks");
const path = require("path");
let ses = new aws.SES({
    region: "us-east-1"
});
exports.handler = (event, context, callback) => {
    let body = buildEmail();
    // AWSLambda.SendEmailRequest 
    let params = {
        Destination: {
            ToAddresses: ["sebasporto@gmail.com"]
        },
        Message: {
            Subject: {
                Data: "Hello"
            },
            Body: {
                Text: {
                    Data: body,
                },
            },
        },
        Source: process.env.SYSTEM_EMAIL || "",
    };
    console.log("Sending");
    var email = ses.sendEmail(params, function (err, data) {
        if (err)
            console.log(err);
        else {
            console.log("===EMAIL SENT===");
            console.log(data);
            console.log("EMAIL CODE END");
            console.log('EMAIL: ', email);
            // context.succeed(event);
            callback(null, "OK");
        }
    });
};
function buildEmail() {
    let data = {
        name: "Sam",
    };
    let tem = path.join(__dirname, "templates", "invite.mjml");
    let res = nunjucks.render(tem, data);
    let compiled = mjml2html(res, {});
    return compiled.html;
}
