# Development

## Build binaries

In api folder run:

  just build-graph
  just build-mail
  ...

## Run the GraphQl server locally

In order to run the server locally it has to be done using SAM local.

To generate the SAM template run (this needs to be done only when serverless.yml changes):

  just api/generate-sam


CodeUri needs to change to local path where the bin directory is e.g.

From `/Users/.../kic/api/.serverless/hello.zip`

To `./`

Then run the SAM local server:

  just api/sam-local
