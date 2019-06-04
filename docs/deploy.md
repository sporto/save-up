Deployment
==========

API
---

The GraphQL API is deployed automatically using Render via Github hooks.

Lambda functions
----------------

The app sends emails using AWS SES. This runs inside lambda.
To deploy we use Serverless.

Client
------

The client is published to Netlify. Simply pushing to master will trigger a Netlify build.

Web: Static site
----------------

This one is published with Netlify as well. Pushing to master will trigger the build.
