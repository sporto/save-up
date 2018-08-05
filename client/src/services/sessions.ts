import * as tokens from "./tokens"
import { SIGN_IN_PATH } from "./constants"
import getConfig from "./config"
import Amplify, { Auth } from "aws-amplify"

function configureAmplifyClient() {
	let config = getConfig()

	Amplify.configure({
		Auth: {
	
			// REQUIRED only for Federated Authentication - Amazon Cognito Identity Pool ID
			// identityPoolId: 'XX-XXXX-X:XXXXXXXX-XXXX-1234-abcd-1234567890ab',
			
			// REQUIRED - Amazon Cognito Region
			region: config.cognitoRegion,
	
			// OPTIONAL - Amazon Cognito Federated Identity Pool Region 
			// Required only if it's different from Amazon Cognito Region
			// identityPoolRegion: 'XX-XXXX-X',
	
			// OPTIONAL - Amazon Cognito User Pool ID
			userPoolId: config.cognitoUserPoolId,
	
			// OPTIONAL - Amazon Cognito Web Client ID (26-char alphanumeric string)
			userPoolWebClientId: config.cognitoClientId,
	
			// OPTIONAL - Enforce user authentication prior to accessing AWS resources or not
			// mandatorySignIn: false,
	
			// OPTIONAL - Configuration for cookie storage
			// cookieStorage: {
			// REQUIRED - Cookie domain (only required if cookieStorage is provided)
				// domain: '.yourdomain.com',
			// OPTIONAL - Cookie path
				// path: '/',
			// OPTIONAL - Cookie expiration in days
				// expires: 365,
			// OPTIONAL - Cookie secure flag
				// secure: true
			// },
	
			// OPTIONAL - customized storage object
			// storage: new MyStorage(),
			
			// OPTIONAL - Manually set the authentication flow type. Default is 'USER_SRP_AUTH'
			authenticationFlowType: 'USER_PASSWORD_AUTH'
		}
	})

	return Amplify
}

export function signUp(signUp: SignUp): void {
	configureAmplifyClient()

	Auth.signUp({
		username: signUp.email,
		password: signUp.password,
		attributes: {
			email: signUp.email,
			name: signUp.name,
			zoneinfo: signUp.timezone,
		}
	})
	.then(data => console.log("data", data))
	.catch(err => console.log("err", err))
}

export function newSession(token: string): void {
	tokens.storeToken(token)
	redirectToEntry(token)
}

export function redirectToEntry(token: string): void {
	tokens.decodeToken(token)
		.map(
			decoded => window.location.href = getEntryUrlForToken(decoded)
		)
}

export function redirectToSignIn() {
	window.location.href = SIGN_IN_PATH
}

export function getEntryUrlForToken(token: Token): string {
	return token.role == "admin"
		? "/admin"
		: "/investor"
}

export function proceedIfSignedIn(callback: (token: Token) => void): void {
	let maybeToken = tokens.getTokenDecoded()

	if (maybeToken.isDefined()) {
		maybeToken.map(callback)
	} else {
		console.log("No token found - redirecting")
		redirectToSignIn()
	}
}

export function proceedIfSignedOut(callback: () => void): void {
	callback()
	// let maybeToken = tokens.getToken()

	// if (maybeToken.isDefined()) {
	// 	maybeToken.map(token => redirectToEntry(token))
	// } else {
	// 	console.log("No token found - render page")
	// 	callback()
	// }
}

export function signOut() {
	tokens.removeToken()
	redirectToSignIn()
}
