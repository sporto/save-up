export const TOKEN_KEY = "save-up-token"

export function getToken(): string | null {
	return localStorage.getItem(TOKEN_KEY)
}

export function removeToken(): void {
	return localStorage.removeItem(TOKEN_KEY)
}

export function storeToken(token: string): void {
	return localStorage.setItem(TOKEN_KEY, token)
}

