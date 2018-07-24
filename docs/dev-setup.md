# Dev setup

The following tools are required:

- http://invoker.codemancers.com/
- Direnv
- Just
- Postgres
- Docker
- Node + Yarn
- Elm
- Rust + Cargo

For deployment
==============

Cross compile directly from Mac (Doesn't work)

Add target

  rustup target add x86_64-unknown-linux-musl

Install musl

https://www.musl-libc.org

On Mac:

  brew install FiloSottile/musl-cross/musl-cross
