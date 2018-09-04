# Development setup

The following tools are required:

- Direnv
- Just
- Postgres
- Docker
- Node + Yarn
- Elm
- Rust + Cargo
- Overmind (Process manager) https://github.com/DarthSim/overmind
- Guttenberg for the static site https://www.getgutenberg.io
- Netlify CLI https://github.com/netlify/netlifyctl/blob/master/README.md

## Environment variables during dev

This API needs a DATABASE_URL env var.
This is specified in `env.xxx.json`.
As the API runs on Docker it needs to resolve to localhost during dev.

On a mac use something like:

```
postgres://postgres@docker.for.mac.localhost/kic_dev
```

## AWS Setup

Install aws cli

Generate IAM access keys from AWS console. Must have permissions to:

- AmazonS3FullAccess

```
aws configure --profile=something
```
