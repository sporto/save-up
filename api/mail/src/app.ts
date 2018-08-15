import * as mjml2html from "mjml"
import * as nunjucks from "nunjucks"

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

var res = nunjucks.renderString(template, data);

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
