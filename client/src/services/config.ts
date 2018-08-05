export default function getConfig(): Config {
	return {
		apiHost: API_HOST,
		cognitoUserPoolId: COGNITO_USER_POOL_ID,
		cognitoRegion: COGNITO_REGION,
		cognitoClientId: COGNITO_APP_CLIENT_ID,
	}
}
