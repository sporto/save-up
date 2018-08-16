// @ts-ignore
import * as mjml2html from "mjml"
import * as nunjucks from "nunjucks"
import * as path from "path"

exports.lambda_handler = async (event: AWSLambda.APIGatewayEvent, context: AWSLambda.Context, callback: AWSLambda.Callback) => {
	let data = {
		name: "Sam",
	}
	
	let tem = path.join(__dirname, "templates", "invite.mjml")
	let res = nunjucks.render(tem, data)
	let compiled = mjml2html(res, {})

	callback(null, compiled)
}
