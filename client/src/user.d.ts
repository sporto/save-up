interface Token {
    role: string,
}

interface PublicFlags {
    apiHost: string,
}

interface CommonPorts {
    toJsSignOut: {
        subscribe(f: () => void): void,
    }
}
