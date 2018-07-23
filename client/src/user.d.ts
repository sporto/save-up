declare var API_HOST: string

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
