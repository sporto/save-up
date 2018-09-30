declare var GraphiQL: any
declare var ReactDOM: any
declare var React: any

import * as session from "./sessions"
import getConfig from "./config"

let token = session.getToken()

console.log("token", token)

function graphQLFetcher(graphQLParams: any) {
	let config = getConfig()

	return fetch(config.apiHost + "/graphql-app", {
		method: "post",
		headers: {
			"Content-Type": "application/json",
			"Authorization": "Bearer " + token,
		},
		body: JSON.stringify(graphQLParams),
	}).then(response => response.json());

}

let node = document.getElementById("app")

ReactDOM.render(
	React.createElement(GraphiQL, { fetcher: graphQLFetcher }),
	node,
)
