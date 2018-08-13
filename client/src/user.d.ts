declare var API_HOST: string

interface Config {
	apiHost: string,
}

interface TokenData {
	name: string,
	email: string,
	role: string,
}

interface TokenAndData {
	token: string,
	data: TokenData,
}

interface PublicFlags {
	apiHost: string,
}

interface Flags {
	apiHost: string,
	token: string,
	tokenData: TokenData,
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
