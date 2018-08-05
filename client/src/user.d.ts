declare var API_HOST: string
declare var COGNITO_APP_CLIENT_ID: string
declare var COGNITO_REGION: string
declare var COGNITO_USER_POOL_ID: string

interface Config {
	apiHost: string,
	cognitoUserPoolId: string,
	cognitoRegion: string,
	cognitoClientId: string,
}

interface Token {
	name: string,
	email: string,
	role: string,
}

interface PublicFlags {
	apiHost: string,
}

interface Flags {
	apiHost: string,
	token: Token,
}

interface CommonPorts {
	toJsSignOut: {
		subscribe(f: () => void): void,
	}
}

interface SignUp {
	email: string,
	name: string,
	password: string,
	timezone: string,
}
