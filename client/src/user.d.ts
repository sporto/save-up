interface Token {
    role: string,
}

interface CommonPorts {
    toJsSignOut: {
        subscribe(f: () => void): void,
    }
}
