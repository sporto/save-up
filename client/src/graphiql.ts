declare var GraphiQL: any
declare var ReactDOM: any
declare var React: any

import * as sessions from "./services/sessions"
import getConfig from "./services/config"

sessions.proceedIfSignedIn(function(tokenAndData: TokenAndData) {

	function graphQLFetcher(graphQLParams: any) {
		let config = getConfig()

		return fetch(config.apiHost + "/graphql", {
			method: "post",
			headers: {
				"Content-Type": "application/json",
				"Authorization": "Bearer " + tokenAndData.token,
			},
			body: JSON.stringify(graphQLParams),
		}).then(response => response.json());

	}

	let node = document.getElementById("app")

	ReactDOM.render(
		React.createElement(GraphiQL, {fetcher: graphQLFetcher}),
		node,
	)

})
