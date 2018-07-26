#!/bin/bash
# Build everything and deploy this app to Heroku

# Build
docker build \
  -f Dockerfile.release \
  -t kic-api .

docker run -it \
  -v $PWD:/volume \
  -v cargo-cache:/root/.cargo \
  kic-api \
  cargo build -Z unstable-options --release --out-dir /volume/bin

# git add -f bin/api
# git ci . -m 'Temporary Heroku-only deployment commit'
# git push heroku master --force

# Un-stage the generated files to finish
# git reset HEAD -f bin/api

rm bin/build-script-build
rm bin/build-script-main

aws deploy push \
  --application-name KicApi \
  --s3-location s3://kic-api-deploys/kic.zip \
  --source bin
