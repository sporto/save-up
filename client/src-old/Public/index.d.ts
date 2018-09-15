// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Elm {
  namespace Public {
    export interface App {
      ports: {
        toJsUseToken: {
          subscribe(callback: (data: string) => void): void
        }
        toJsSignOut: {
          subscribe(callback: (data: null) => void): void
        }
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: { apiHost: string };
    }): Elm.Public.App;
  }
}