# Deployment

## API

The API is built using docker and then deployed to Heroku

To build a relase run:

```
just api/build-release
```

This will generate a binary inside api/release

Then push to Heroku using

```
just deploy
```

## Client

The client is published to Netlify. Simply pushing to master will trigger a Netlify build.
