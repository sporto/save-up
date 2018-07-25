Deployment
==========

API
---

The API is built using docker and then deployed to Heroku

To build a relase run:

```
just api/build-release
```

This will generate a binary inside api/release

Then push to Heroku using

```
just api/deploy
```

Client
------

The client is published to Netlify. Simply pushing to master will trigger a Netlify build.

Web: Static site
----------------

This one is published with Netlify as well. Pushing to master will trigger the build.
