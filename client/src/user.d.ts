declare var API_HOST: string

interface Config {
	apiHost: string,
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
