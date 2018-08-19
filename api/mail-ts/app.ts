// @ts-ignore
import * as mjml2html from "mjml"
import * as aws from "aws-sdk"
import * as nunjucks from "nunjucks"
import * as path from "path"

let ses = new aws.SES({
	region: "us-east-1"
})

exports.handler = (event: AWSLambda.APIGatewayEvent, context: AWSLambda.Context, callback: AWSLambda.Callback) => {
	let body = buildEmail()

	// AWSLambda.SendEmailRequest 
	let params: AWS.SES.SendEmailRequest = {
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
	}

	console.log("Sending")

	var email = ses.sendEmail(params, function(err, data){
		if(err) console.log(err);
		else {
			console.log("===EMAIL SENT===");
			console.log(data);

			console.log("EMAIL CODE END");
			console.log('EMAIL: ', email);
			// context.succeed(event);
			callback(null, "OK")
		}
	})
}

function buildEmail(): string {
	let data = {
		name: "Sam",
	}

	let tem = path.join(__dirname, "templates", "invite.mjml")
	let res = nunjucks.render(tem, data)
	let compiled = mjml2html(res, {})

	return compiled.html
}
