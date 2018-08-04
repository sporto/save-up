# KIC API

Built using AWS Lambda, Rust and SAM

# Environment variables during dev

This API needs a DATABASE_URL env var.
This is specified in `env.xxx.json`.
As the API runs on Docker it needs to resolve to localhost during dev.

On a mac use something like:

```
postgres://postgres@docker.for.mac.localhost/kic_dev
```


