declare var API_HOST: string

export default function getConfig() {
	let apiHost = process.env.API_HOST

	return {
		apiHost
	}
}
