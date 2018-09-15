// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Elm {
  namespace App {
    export interface App {
      ports: {
        toJsStoreToken: {
          subscribe(callback: (data: string) => void): void
        }
        toJsRemoveToken: {
          subscribe(callback: (data: null) => void): void
        }
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: { apiHost: string; token: string | null };
    }): Elm.App.App;
  }
}