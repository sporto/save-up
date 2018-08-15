// @ts-ignore
import * as mjml2html from "mjml"
import * as nunjucks from "nunjucks"
import * as path from "path"

let data = {
	name: "Sam",
}

var template  = `
<mjml>
	<mj-body>
		<mj-section>
			<mj-column>
				<mj-text>
					Hello {{name}}!
				</mj-text>
			</mj-column>
		</mj-section>
	</mj-body>
</mjml>
`

let tem = path.join(__dirname, "templates", "invite.mjml")
var res = nunjucks.render(tem, data);

console.log(res)

/*
  Compile an mjml string
*/
const htmlOutput = mjml2html(`
	<mjml>
		<mj-body>
			<mj-section>
				<mj-column>
					<mj-text>
						Hello {{name}}!
					</mj-text>
				</mj-column>
			</mj-section>
		</mj-body>
	</mjml>
`, {})


/*
  Print the responsive HTML generated and MJML errors if any
*/
// console.log(htmlOutput)
