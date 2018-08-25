# Development

## Build binaries

In api folder run:

  just build-graph
  just build-mail
  ...

## Run the GraphQl server locally

In order to run the server locally there is a SAM template.yaml.
This contains functions for the graphql.

Then run the SAM local server:

  just api/sam-local
