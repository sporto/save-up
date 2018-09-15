declare var API_HOST: string

export interface Config {
	apiHost: string,
}

export interface TokenData {
	name: string,
	email: string,
	role: string,
}

export interface TokenAndData {
	token: string,
	data: TokenData,
}

export interface PublicFlags {
	apiHost: string,
}

export interface Flags {
	apiHost: string,
	token: string,
	tokenData: TokenData,
}

export interface SignUp {
	email: string,
	name: string,
	password: string,
	timezone: string,
}
